module Customers
  class MeController < ApplicationController
    def show
      return head(:unauthorized) unless Current.actor
      return head(:unauthorized) unless Current.actor.roles.where(name: "customer").exists?

      render json: {
        id: Current.actor.id,
        email: Current.actor.email,
        full_name: Current.actor.full_name,
        phone: Current.actor.phone,
        business_id: Current.actor.business_id,
        roles: Current.actor.roles.pluck(:name)
      }
    end
  end
end
