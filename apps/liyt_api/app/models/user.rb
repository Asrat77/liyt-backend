class User < ApplicationRecord
  belongs_to :business

  has_many :refresh_tokens, as: :owner, dependent: :destroy

  include RoleHelpers

  has_secure_password

  validates :email, presence: true, uniqueness: { scope: :business_id }
  validates :password_digest, presence: true
end
