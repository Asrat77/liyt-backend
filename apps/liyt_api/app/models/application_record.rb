class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.current_tenant
    Current.tenant
  end

  def self.current_actor
    Current.actor
  end
end
