class User < ApplicationRecord
  belongs_to :business

  has_many :refresh_tokens, as: :owner, dependent: :destroy

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
