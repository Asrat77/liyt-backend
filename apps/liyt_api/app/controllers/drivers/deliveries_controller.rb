module Drivers
  class DeliveriesController < ApplicationController
    before_action :ensure_driver_authenticated
    before_action :set_delivery, only: [ :accept, :pickup, :complete ]

    def index
      deliveries = Delivery.where(status: [ :pending, :accepted, :picked_up ])
        .where(driver_id: [ nil, Current.driver.id ])
        .order(created_at: :desc)

      render json: deliveries.map { |delivery| delivery_summary_response(delivery) }
    end

    def show
      delivery = Delivery.find_by(id: params[:id], driver_id: [ nil, Current.driver.id ])
      return head(:not_found) unless delivery

      render json: delivery_full_response(delivery)
    end

    def accept
      return render json: { error: "not_available" }, status: :unprocessable_entity unless @delivery.pending?
      return render json: { error: "already_assigned" }, status: :unprocessable_entity if @delivery.driver_id.present? && @delivery.driver_id != Current.driver.id

      ApplicationRecord.transaction do
        @delivery.update!(
          driver: Current.driver,
          status: :accepted,
          accepted_at: Time.current
        )

        DeliveryEvent.create!(
          delivery: @delivery,
          event_type: "accepted",
          from_status: :pending,
          to_status: :accepted,
          actor_type: "Driver",
          actor_id: Current.driver.id,
          occurred_at: Time.current
        )
      end

      render json: delivery_full_response(@delivery)
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "accept_failed", message: e.message }, status: :unprocessable_entity
    end

    def pickup
      return render json: { error: "not_accepted" }, status: :unprocessable_entity unless @delivery.accepted?
      return render json: { error: "not_assigned_to_you" }, status: :forbidden unless @delivery.driver_id == Current.driver.id

      ApplicationRecord.transaction do
        @delivery.update!(
          status: :picked_up,
          picked_up_at: Time.current
        )

        DeliveryEvent.create!(
          delivery: @delivery,
          event_type: "picked_up",
          from_status: :accepted,
          to_status: :picked_up,
          actor_type: "Driver",
          actor_id: Current.driver.id,
          occurred_at: Time.current
        )
      end

      render json: delivery_full_response(@delivery)
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "pickup_failed", message: e.message }, status: :unprocessable_entity
    end

    def complete
      return render json: { error: "not_picked_up" }, status: :unprocessable_entity unless @delivery.picked_up? || @delivery.in_transit?
      return render json: { error: "not_assigned_to_you" }, status: :forbidden unless @delivery.driver_id == Current.driver.id

      ApplicationRecord.transaction do
        @delivery.update!(
          status: :delivered,
          delivered_at: Time.current
        )

        DeliveryEvent.create!(
          delivery: @delivery,
          event_type: "delivered",
          from_status: @delivery.status_before_last_save,
          to_status: :delivered,
          actor_type: "Driver",
          actor_id: Current.driver.id,
          occurred_at: Time.current
        )
      end

      render json: delivery_full_response(@delivery)
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "complete_failed", message: e.message }, status: :unprocessable_entity
    end

    private

    def ensure_driver_authenticated
      head(:unauthorized) unless Current.driver
    end

    def set_delivery
      @delivery = Delivery.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head(:not_found)
    end

    def delivery_summary_response(delivery)
      pickup = delivery.pickup_stop
      dropoff = delivery.dropoff_stop

      {
        id: delivery.id,
        public_id: delivery.public_id,
        status: delivery.status,
        price: delivery.price,
        description: delivery.description,
        pickup_address: pickup ? {
          city: pickup.city,
          region: pickup.region
        } : nil,
        dropoff_address: dropoff ? {
          city: dropoff.city,
          region: dropoff.region
        } : nil,
        created_at: delivery.created_at
      }
    end

    def delivery_full_response(delivery)
      {
        id: delivery.id,
        public_id: delivery.public_id,
        status: delivery.status,
        price: delivery.price,
        description: delivery.description,
        driver_id: delivery.driver_id,
        business: delivery.business ? {
          id: delivery.business.id,
          name: delivery.business.name
        } : nil,
        customer: delivery.customer ? {
          id: delivery.customer.id,
          full_name: delivery.customer.full_name,
          phone: delivery.customer.phone
        } : nil,
        pickup: delivery.pickup_stop ? stop_response(delivery.pickup_stop) : nil,
        dropoff: delivery.dropoff_stop ? stop_response(delivery.dropoff_stop) : nil,
        items: delivery.delivery_items.map { |item| { name: item.name, quantity: item.quantity } },
        accepted_at: delivery.accepted_at,
        picked_up_at: delivery.picked_up_at,
        delivered_at: delivery.delivered_at,
        created_at: delivery.created_at
      }
    end

    def stop_response(stop)
      {
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
end
