module Customers
  class DeliveriesController < ApplicationController
    before_action :ensure_customer_role

    def index
      deliveries = Delivery.where(customer_id: customer_ids_for_user)
        .order(created_at: :desc)

      render json: deliveries.map { |delivery| delivery_summary_response(delivery) }
    end

    def show
      delivery = Delivery.find_by(id: params[:id], customer_id: customer_ids_for_user)
      return head(:not_found) unless delivery

      render json: delivery_full_response(delivery)
    end

    def history
      deliveries = Delivery.for_customer_email(Current.actor.email)

      # Status filter (accepts comma-separated or array)
      statuses = params[:status] || params[:statuses]
      if statuses.present?
        statuses = statuses.is_a?(Array) ? statuses : statuses.to_s.split(",").map(&:strip)
        deliveries = deliveries.with_statuses(statuses)
      end

      # Text search
      deliveries = deliveries.search_text(params[:q] || params[:search])

      # City filters
      deliveries = deliveries.by_pickup_city(params[:pickup_city])
      deliveries = deliveries.by_dropoff_city(params[:dropoff_city])

      # Price filters
      deliveries = deliveries.min_price(params[:min_price])
      deliveries = deliveries.max_price(params[:max_price])

      # Date range filter (defaults to delivered_at)
      date_field = params[:date_field] || "delivered_at"
      deliveries = deliveries.between_dates(date_field, params[:from], params[:to])

      # Ordering (whitelist)
      allowed_order = %w[delivered_at created_at accepted_at price]
      order_by = allowed_order.include?(params[:order_by]) ? params[:order_by] : "delivered_at"
      order_direction = params[:order_direction] == "asc" ? :asc : :desc
      deliveries = deliveries.order(order_by => order_direction)

      # Pagination
      page = (params[:page] || 1).to_i
      page = 1 if page <= 0
      per_page = (params[:per_page] || 20).to_i
      per_page = 20 if per_page <= 0
      per_page = [ per_page, 100 ].min

      total_count = deliveries.count
      deliveries = deliveries.offset((page - 1) * per_page).limit(per_page)

      render json: {
        data: deliveries.map { |delivery| delivery_summary_response(delivery) },
        meta: {
          page: page,
          per_page: per_page,
          total_count: total_count
        }
      }
    end

    private

    def ensure_customer_role
      return head(:unauthorized) unless Current.actor
      return head(:unauthorized) unless Current.actor.roles.where(name: "customer").exists?
    end

    def customer_ids_for_user
      Customer.where(email: Current.actor.email).pluck(:id)
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
