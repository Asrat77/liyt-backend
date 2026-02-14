class CustomerLocation < ApplicationRecord
  belongs_to :customer

  validates :customer, presence: true
  validates :latitude,
    numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 },
    allow_nil: true
  validates :longitude,
    numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 },
    allow_nil: true
end
