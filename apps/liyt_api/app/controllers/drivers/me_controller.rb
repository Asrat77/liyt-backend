module Drivers
  class MeController < ApplicationController
    def show
      return head(:unauthorized) unless Current.driver

      render json: {
        id: Current.driver.id,
        email: Current.driver.email,
        full_name: Current.driver.full_name,
        phone: Current.driver.phone,
        status: Current.driver.status,
        vehicle_type: Current.driver.vehicle_type,
        license_number: Current.driver.license_number,
        verified_at: Current.driver.verified_at,
        rating: Current.driver.rating,
        last_latitude: Current.driver.last_latitude,
        last_longitude: Current.driver.last_longitude,
        last_location_at: Current.driver.last_location_at
      }
    end
  end
end
