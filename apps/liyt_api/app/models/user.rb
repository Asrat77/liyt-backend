class User < ApplicationRecord
  belongs_to :business

  has_many :refresh_tokens, as: :owner, dependent: :destroy
  has_many :created_api_keys, class_name: "ApiKey", foreign_key: :created_by_user_id, dependent: :nullify
  has_many :revoked_api_keys, class_name: "ApiKey", foreign_key: :revoked_by_user_id, dependent: :nullify

  include RoleHelpers

  has_secure_password

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password_digest, presence: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
