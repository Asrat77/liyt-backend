module RoleHelpers
  extend ActiveSupport::Concern

  included do
    has_many :user_roles, dependent: :destroy
    has_many :roles, through: :user_roles
  end

  def admin?
    roles.where(name: "admin").exists?
  end

  def staff?
    roles.where(name: "staff").exists?
  end
end
