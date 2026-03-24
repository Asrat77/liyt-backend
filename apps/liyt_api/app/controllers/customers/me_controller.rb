module Customers
  class MeController < ApplicationController
    def show
      return head(:unauthorized) unless Current.actor
      return head(:unauthorized) unless Current.actor.roles.where(name: "customer").exists?

      render json: {
        id: Current.actor.id,
        email: Current.actor.email,
        business_id: Current.actor.business_id,
        roles: Current.actor.roles.pluck(:name)
      }
    end
  end
end
