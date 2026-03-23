class BusinessSetting < ApplicationRecord
  belongs_to :business

  validates :business, presence: true
  validates :business_id, uniqueness: true
end
