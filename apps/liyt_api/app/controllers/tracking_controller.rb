class TrackingController < ApplicationController
  skip_before_action :authenticate_request, only: [ :show ]

  def show
    token = DeliveryTrackingToken.find_by(token_hash: params[:token])
    return head(:not_found) unless token
    return head(:gone) if token.expired?

    delivery = token.delivery
    return head(:not_found) unless delivery

    # Only allow tracking after confirmation (not in awaiting_recipient status)
    return head(:not_found) if delivery.awaiting_recipient?

    driver = delivery.driver

    render json: {
      delivery: {
        public_id: delivery.public_id,
        status: delivery.status,
        price: delivery.price,
        description: delivery.description,
        accepted_at: delivery.accepted_at,
        picked_up_at: delivery.picked_up_at,
        delivered_at: delivery.delivered_at,
        business: delivery.business ? {
          name: delivery.business.name
        } : nil,
        driver: driver ? {
          full_name: driver.full_name,
          phone: driver.phone,
          vehicle_type: driver.vehicle_type,
          last_latitude: driver.last_latitude,
          last_longitude: driver.last_longitude,
          last_location_at: driver.last_location_at
        } : nil,
        pickup: delivery.pickup_stop ? stop_response(delivery.pickup_stop) : nil,
        dropoff: delivery.dropoff_stop ? stop_response(delivery.dropoff_stop) : nil
      }
    }
  end

  private

  def stop_response(stop)
    {
      address1: stop.address1,
      address2: stop.address2,
      city: stop.city,
      region: stop.region,
      contact_name: stop.contact_name,
      contact_phone: stop.contact_phone
    }
  end
end
