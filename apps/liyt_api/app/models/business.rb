class Business < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :refresh_tokens, through: :users

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
