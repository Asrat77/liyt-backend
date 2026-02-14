class DeliveryTrackingToken < ApplicationRecord
  belongs_to :delivery

  validates :delivery, presence: true
  validates :token_hash, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  private

  def generate_token
    return if token_hash.present?

    raw_token = SecureRandom.urlsafe_base64(32)
    self.token_hash = Digest::SHA256.hexdigest(raw_token)
    self.expires_at = 30.days.from_now

    @raw_token = raw_token
  end

  attr_reader :raw_token
end
