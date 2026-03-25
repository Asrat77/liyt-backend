module Customers
  class ConfirmationsController < ApplicationController
    skip_before_action :authenticate_request, only: [ :show, :confirm ]

    def show
      token = DeliveryTrackingToken.find_by(token_hash: params[:token])
      return head(:not_found) unless token
      return head(:gone) if token.expired?

      delivery = token.delivery
      return head(:not_found) unless delivery

      render json: {
        delivery: {
          public_id: delivery.public_id,
          status: delivery.status,
          description: delivery.description,
          price: delivery.price,
          business: delivery.business ? {
            id: delivery.business.id,
            name: delivery.business.name
          } : nil,
          pickup: delivery.pickup_stop ? stop_response(delivery.pickup_stop) : nil,
          items: delivery.delivery_items.map { |item| { name: item.name, quantity: item.quantity } }
        }
      }
    end

    def confirm
      token = DeliveryTrackingToken.find_by(token_hash: params[:token])
      return head(:not_found) unless token
      return head(:gone) if token.expired?

      delivery = token.delivery
      return head(:not_found) unless delivery
      return render json: { error: "already_confirmed" }, status: :unprocessable_entity unless delivery.awaiting_recipient?

      ApplicationRecord.transaction do
        customer = find_or_create_customer
        assign_customer_signin_role(delivery)
        create_customer_location(customer) if confirmation_params[:location].present?

        delivery.update!(
          customer: customer,
          status: :pending
        )

        create_dropoff_stop(delivery, confirmation_params[:dropoff] || confirmation_params[:location])

        DeliveryEvent.create!(
          delivery: delivery,
          event_type: "confirmed",
          from_status: :awaiting_recipient,
          to_status: :pending,
          actor_type: "Customer",
          actor_id: customer.id,
          occurred_at: Time.current
        )
      end

      render json: {
        message: "Delivery confirmed successfully",
        delivery: {
          public_id: delivery.public_id,
          status: delivery.status,
          tracking_url: generate_tracking_url(token)
        }
      }
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "confirmation_failed", message: e.message }, status: :unprocessable_entity
    end

    private

    def confirmation_params
      params.permit(
        :token,
        :full_name,
        :phone,
        :email,
        :password,
        dropoff: [ :address1, :address2, :city, :region, :postal_code, :country_code, :latitude, :longitude, :instructions ],
        location: [ :address1, :address2, :city, :region, :postal_code, :country_code, :latitude, :longitude, :instructions, :name ]
      )
    end

    def find_or_create_customer
      if confirmation_params[:email].present?
        customer = Customer.find_by(email: confirmation_params[:email])
        return customer if customer
      end

      Customer.create!(
        full_name: confirmation_params[:full_name],
        phone: confirmation_params[:phone],
        email: confirmation_params[:email]
      )
    end

    def assign_customer_signin_role(delivery)
      return unless confirmation_params[:email].present? && confirmation_params[:password].present?

      user = find_or_create_customer_user(delivery)
      role = Role.find_or_create_by!(business: delivery.business, name: "customer")

      UserRole.find_or_create_by!(user: user, role: role)
    end

    def find_or_create_customer_user(delivery)
      email = confirmation_params[:email].to_s.strip.downcase
      user = User.find_by(email: email)

      return User.create!(
        business: delivery.business,
        email: email,
        password: confirmation_params[:password]
      ) unless user

      if user.business_id != delivery.business_id
        user.errors.add(:business, "must match delivery business")
        raise ActiveRecord::RecordInvalid, user
      end

      user
    end

    def create_customer_location(customer)
      location_params = confirmation_params[:location]
      return unless location_params.present?

      customer.customer_locations.create!(
        name: location_params[:name] || "Home",
        address1: location_params[:address1],
        address2: location_params[:address2],
        city: location_params[:city],
        region: location_params[:region],
        postal_code: location_params[:postal_code],
        country_code: location_params[:country_code],
        latitude: location_params[:latitude],
        longitude: location_params[:longitude],
        instructions: location_params[:instructions],
        is_default: customer.customer_locations.empty?
      )
    end

    def create_dropoff_stop(delivery, dropoff_params)
      return unless dropoff_params.present?

      delivery.delivery_stops.create!(
        kind: "dropoff",
        sequence: 1,
        address1: dropoff_params[:address1],
        address2: dropoff_params[:address2],
        city: dropoff_params[:city],
        region: dropoff_params[:region],
        postal_code: dropoff_params[:postal_code],
        country_code: dropoff_params[:country_code],
        latitude: dropoff_params[:latitude],
        longitude: dropoff_params[:longitude],
        instructions: dropoff_params[:instructions]
      )
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

    def generate_tracking_url(token)
      base_url = ENV.fetch("FRONTEND_URL", "https://liyt.com")
      "#{base_url}/track/#{token.token_hash}"
    end
  end
end
