class DeliveryItem < ApplicationRecord
  belongs_to :delivery

  validates :delivery, presence: true
  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
