module Drivers
  class RegistrationsController < ApplicationController
    include TokenIssuer

    skip_before_action :authenticate_request, only: [ :create ]

    def create
      driver = Driver.create!(
        email: params[:email],
        password: params[:password]
      )

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
        email: driver.email
      }
    end
  end
end
