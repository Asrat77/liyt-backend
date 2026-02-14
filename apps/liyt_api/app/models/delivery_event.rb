class DeliveryEvent < ApplicationRecord
  belongs_to :delivery

  validates :delivery, presence: true
  validates :event_type, presence: true
  validates :occurred_at, presence: true
end
