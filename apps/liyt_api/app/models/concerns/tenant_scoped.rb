module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :business
    default_scope do
      Current.tenant ? where(business_id: Current.tenant.id) : none
    end
  end
end
