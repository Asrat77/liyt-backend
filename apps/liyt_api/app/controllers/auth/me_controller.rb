module Auth
  class MeController < ApplicationController
    def show
      render json: {
        id: Current.actor.id,
        email: Current.actor.email,
        business_id: Current.tenant.id,
        roles: Current.actor.roles.pluck(:name)
      }
    end
  end
end
