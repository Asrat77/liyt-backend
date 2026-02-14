class Customer < ApplicationRecord
  has_many :customer_locations, dependent: :destroy
  has_many :deliveries, dependent: :nullify

  validates :full_name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active inactive] }

  before_validation :normalize_phone

  private

  def normalize_phone
    self.phone = phone.to_s.strip
  end
end
