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

  # Scopes and helpers used by the drivers deliveries history endpoint
  scope :for_driver, ->(driver_id) { where(driver_id: driver_id) }

  scope :with_statuses, ->(statuses) {
    return all unless statuses.present?
    keys = Array(statuses).map(&:to_s)
    ints = keys.map { |k| self.statuses[k] }.compact
    where(status: ints)
  }

  def self.between_dates(field, from, to)
    allowed = %w[delivered_at created_at accepted_at]
    field = allowed.include?(field.to_s) ? field.to_s : "delivered_at"
    scope = all
    scope = scope.where("#{field} >= ?", from) if from.present?
    scope = scope.where("#{field} <= ?", to) if to.present?
    scope
  end

  scope :search_text, ->(q) {
    return all unless q.present?
    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
    left_outer_joins(:customer).where(
      "deliveries.public_id ILIKE :q OR customers.full_name ILIKE :q OR customers.email ILIKE :q OR customers.phone ILIKE :q",
      q: pattern
    )
  }

  scope :by_pickup_city, ->(city) {
    return all unless city.present?
    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(city)}%"
    joins(:delivery_stops).where("delivery_stops.kind = 'pickup' AND delivery_stops.city ILIKE ?", pattern).distinct
  }

  scope :by_dropoff_city, ->(city) {
    return all unless city.present?
    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(city)}%"
    joins(:delivery_stops).where("delivery_stops.kind = 'dropoff' AND delivery_stops.city ILIKE ?", pattern).distinct
  }

  scope :min_price, ->(amount) { return all unless amount.present?; where("price >= ?", amount) }
  scope :max_price, ->(amount) { return all unless amount.present?; where("price <= ?", amount) }

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
