module Customers
  class MeController < ApplicationController
    def show
      return head(:unauthorized) unless Current.actor
      return head(:unauthorized) unless Current.actor.roles.where(name: "customer").exists?

      customer = Customer.find_by(email: Current.actor.email)

      render json: {
        id: Current.actor.id,
        email: Current.actor.email,
        full_name: customer&.full_name,
        phone: customer&.phone,
        business_id: Current.actor.business_id,
        roles: Current.actor.roles.pluck(:name)
      }
    end
  end
end
