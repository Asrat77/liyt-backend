module Authorization
  extend ActiveSupport::Concern

  included do
    before_action :ensure_can_access_account, if: -> { ApplicationRecord.current_tenant && Current.session }
  end

  private

  def ensure_can_access_account
    return head(:unauthorized) unless Current.session

    head :forbidden unless Current.session["biz"] == ApplicationRecord.current_tenant.id
  end

  def ensure_can_administer
    return head(:forbidden) unless Current.actor

    head :forbidden unless Current.actor.roles.where(name: "admin").exists?
  end

  def ensure_is_staff_member
    return head(:forbidden) unless Current.actor

    head :forbidden unless Current.actor.roles.where(name: "staff").exists?
  end
end
