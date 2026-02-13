class Driver < ApplicationRecord
  has_many :refresh_tokens, as: :owner, dependent: :destroy

  has_secure_password

  before_validation :normalize_email
  before_validation :normalize_phone

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :phone, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active suspended] }
  validates :password_digest, presence: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def normalize_phone
    self.phone = phone.to_s.strip
  end
end
