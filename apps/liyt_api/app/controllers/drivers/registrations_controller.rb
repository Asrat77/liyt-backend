module Drivers
  class RegistrationsController < ApplicationController
    include TokenIssuer

    skip_before_action :authenticate_request, only: [ :create ]

    def create
      driver = Driver.create!(driver_params)

      render json: issue_tokens(driver, driver_payload(driver)).merge(
        driver: driver_response(driver)
      ), status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { error: "registration_invalid" }, status: :unprocessable_entity
    end

    private

    def driver_response(driver)
      {
        id: driver.id,
        email: driver.email,
        full_name: driver.full_name,
        phone: driver.phone,
        status: driver.status,
        vehicle_type: driver.vehicle_type,
        license_number: driver.license_number,
        verified_at: driver.verified_at,
        rating: driver.rating,
        last_latitude: driver.last_latitude,
        last_longitude: driver.last_longitude,
        last_location_at: driver.last_location_at
      }
    end

    def driver_params
      params.permit(
        :email,
        :password,
        :full_name,
        :phone,
        :vehicle_type,
        :license_number
      )
    end
  end
end
