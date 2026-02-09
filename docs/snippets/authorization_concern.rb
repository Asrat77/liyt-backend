module Authorization
  extend ActiveSupport::Concern

  included do
    before_action :ensure_can_access_account, if: -> { ApplicationRecord.current_tenant && Current.session }
  end

  private

  def ensure_can_access_account
    return head(:unauthorized) unless Current.session

    # Ensure session's tenant matches current tenant
    return unless Current.session.respond_to?(:business_id) && ApplicationRecord.current_tenant.respond_to?(:id)

    head :forbidden unless Current.session.business_id == ApplicationRecord.current_tenant.id
  end

  def ensure_can_administer
    head :forbidden unless Current.user&.admin?
  end

  def ensure_is_staff_member
    head :forbidden unless Current.user&.staff?
  end
end
