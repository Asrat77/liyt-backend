module Drivers
  class MeController < ApplicationController
    def show
      return head(:unauthorized) unless Current.driver

      render json: {
        id: Current.driver.id,
        email: Current.driver.email
      }
    end
  end
end
