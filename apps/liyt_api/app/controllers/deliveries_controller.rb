class DeliveriesController < ApplicationController
  DELIVERY_WRITE_SCOPE = "deliveries:write".freeze
  PICKUP_REQUIRED_FIELDS = %i[ address1 city region country_code contact_name contact_phone ].freeze

  before_action :ensure_current_tenant
  before_action :ensure_can_create_deliveries, only: [ :create ]
  before_action :ensure_can_administer, only: [ :cancel ]
  before_action :set_delivery, only: [ :show, :cancel ]

  def index
    deliveries = Current.tenant.deliveries.order(created_at: :desc)
    deliveries = deliveries.where(status: params[:status]) if params[:status].present?

    render json: deliveries.map { |delivery| delivery_response(delivery) }
  end

  def show
    render json: delivery_response(@delivery, include_stops: true, include_items: true)
  end

  def create
    pickup_attributes = resolved_pickup_attributes
    missing_pickup_fields = missing_pickup_fields_for(pickup_attributes)
    return render_pickup_invalid(missing_pickup_fields) if missing_pickup_fields.any?

    delivery = nil

    ApplicationRecord.transaction do
      delivery = Delivery.create!(
        business: Current.tenant,
        description: delivery_params[:description],
        price: delivery_params[:price] || 0.0
      )

      create_pickup_stop(delivery, pickup_attributes)
      create_items(delivery, delivery_params[:items])
      create_tracking_token(delivery)

      DeliveryEvent.create!(
        delivery: delivery,
        event_type: "created",
        to_status: delivery.status,
        **event_actor_attributes,
        occurred_at: Time.current
      )
    end

    send_confirmation_email(delivery, delivery_params[:recipient_email])

    render json: delivery_response(delivery, include_stops: true, include_items: true), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "delivery_invalid", message: e.message }, status: :unprocessable_entity
  end

  def cancel
    unless @delivery.can_cancel?
      return render json: { error: "cannot_cancel", message: "Delivery cannot be cancelled at this stage" }, status: :unprocessable_entity
    end

    ApplicationRecord.transaction do
      @delivery.update!(
        status: :cancelled,
        cancelled_at: Time.current,
        cancel_reason: params[:reason]
      )

      DeliveryEvent.create!(
        delivery: @delivery,
        event_type: "cancelled",
        from_status: @delivery.status_before_last_save,
        to_status: :cancelled,
        actor_type: "User",
        actor_id: Current.actor.id,
        note: params[:reason],
        occurred_at: Time.current
      )
    end

    head :no_content
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "cancel_failed", message: e.message }, status: :unprocessable_entity
  end

  private

  def ensure_current_tenant
    head(:unauthorized) unless Current.tenant
  end

  def ensure_can_administer
    head(:forbidden) unless Current.actor&.roles&.exists?(name: "admin")
  end

  def ensure_can_create_deliveries
    return if Current.actor&.roles&.exists?(name: "admin")
    return if Current.api_key&.allows_scope?(DELIVERY_WRITE_SCOPE)

    head :forbidden
  end

  def set_delivery
    @delivery = Current.tenant.deliveries.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head(:not_found)
  end

  def delivery_params
    params.permit(
      :description,
      :price,
      :recipient_email,
      pickup: [ :address1, :address2, :city, :region, :postal_code, :country_code, :latitude, :longitude, :contact_name, :contact_phone, :instructions ],
      items: [ :name, :quantity ]
    )
  end

  def create_pickup_stop(delivery, pickup_params)
    return unless pickup_params.present?

    delivery.delivery_stops.create!(
      kind: "pickup",
      sequence: 0,
      address1: pickup_params[:address1],
      address2: pickup_params[:address2],
      city: pickup_params[:city],
      region: pickup_params[:region],
      postal_code: pickup_params[:postal_code],
      country_code: pickup_params[:country_code],
      latitude: pickup_params[:latitude],
      longitude: pickup_params[:longitude],
      contact_name: pickup_params[:contact_name],
      contact_phone: pickup_params[:contact_phone],
      instructions: pickup_params[:instructions]
    )
  end

  def resolved_pickup_attributes
    default_pickup_attributes.merge(request_pickup_attributes)
  end

  def request_pickup_attributes
    (delivery_params[:pickup]&.to_h || {}).symbolize_keys.reject { |_field, value| value.blank? }
  end

  def default_pickup_attributes
    business_setting = Current.tenant&.business_setting
    return {} unless business_setting

    {
      address1: business_setting.pickup_address1,
      address2: business_setting.pickup_address2,
      city: business_setting.pickup_city,
      region: business_setting.pickup_region,
      postal_code: business_setting.pickup_postal_code,
      country_code: business_setting.pickup_country_code,
      latitude: business_setting.pickup_latitude,
      longitude: business_setting.pickup_longitude,
      contact_name: business_setting.pickup_contact_name,
      contact_phone: business_setting.pickup_contact_phone,
      instructions: business_setting.pickup_instructions
    }
  end

  def missing_pickup_fields_for(pickup_attributes)
    PICKUP_REQUIRED_FIELDS.select { |field| pickup_attributes[field].blank? }
  end

  def render_pickup_invalid(missing_fields)
    render json: {
      error: "pickup_invalid",
      missing_fields: missing_fields
    }, status: :unprocessable_entity
  end

  def create_items(delivery, items_params)
    return unless items_params.present?

    items_params.each do |item_param|
      delivery.delivery_items.create!(
        name: item_param[:name],
        quantity: item_param[:quantity] || 1
      )
    end
  end

  def create_tracking_token(delivery)
    token = delivery.create_delivery_tracking_token!
    raw_token = SecureRandom.urlsafe_base64(32)
    token_hash = Digest::SHA256.hexdigest(raw_token)
    token.update!(token_hash: token_hash, expires_at: 30.days.from_now)
    token.instance_variable_set(:@raw_token, raw_token)
    token
  end

  def event_actor_attributes
    return { actor_type: "User", actor_id: Current.actor.id } if Current.actor
    return { actor_type: "ApiKey", actor_id: Current.api_key.id } if Current.api_key

    {}
  end

  def send_confirmation_email(delivery, recipient_email)
    return unless recipient_email.present?

    DeliveryMailer.confirmation_email(delivery, recipient_email).deliver_later
  end

  def delivery_response(delivery, include_stops: false, include_items: false)
    response = {
      id: delivery.id,
      public_id: delivery.public_id,
      status: delivery.status,
      price: delivery.price,
      description: delivery.description,
      business_id: delivery.business_id,
      driver_id: delivery.driver_id,
      customer_id: delivery.customer_id,
      accepted_at: delivery.accepted_at,
      picked_up_at: delivery.picked_up_at,
      delivered_at: delivery.delivered_at,
      cancelled_at: delivery.cancelled_at,
      cancel_reason: delivery.cancel_reason,
      created_at: delivery.created_at
    }

    if include_stops
      response[:stops] = delivery.delivery_stops.order(:sequence).map do |stop|
        {
          id: stop.id,
          kind: stop.kind,
          sequence: stop.sequence,
          address1: stop.address1,
          address2: stop.address2,
          city: stop.city,
          region: stop.region,
          postal_code: stop.postal_code,
          country_code: stop.country_code,
          latitude: stop.latitude,
          longitude: stop.longitude,
          contact_name: stop.contact_name,
          contact_phone: stop.contact_phone,
          instructions: stop.instructions
        }
      end
    end

    if include_items
      response[:items] = delivery.delivery_items.map do |item|
        {
          id: item.id,
          name: item.name,
          quantity: item.quantity
        }
      end
    end

    response
  end
end
