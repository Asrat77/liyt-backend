class Delivery < ApplicationRecord
  belongs_to :business, optional: true
  belongs_to :driver, optional: true
  belongs_to :customer, optional: true
  has_many :delivery_stops, dependent: :destroy
  has_many :delivery_items, dependent: :destroy
  has_one :delivery_tracking_token, dependent: :destroy
  has_many :delivery_events, dependent: :destroy

  enum :status, {
    awaiting_recipient: 0,
    pending: 1,
    accepted: 2,
    picked_up: 3,
    in_transit: 4,
    delivered: 5,
    cancelled: 6
  }, default: :awaiting_recipient

  validates :public_id, presence: true, uniqueness: true

  before_validation :generate_public_id, on: :create

  def pickup_stop
    delivery_stops.find_by(kind: "pickup")
  end

  def dropoff_stop
    delivery_stops.find_by(kind: "dropoff")
  end

  def can_cancel?
    awaiting_recipient? || pending?
  end

  private

  def generate_public_id
    return if public_id.present?

    self.public_id = SecureRandom.alphanumeric(12).upcase
  end
end
