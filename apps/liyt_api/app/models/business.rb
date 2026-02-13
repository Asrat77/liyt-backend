class Business < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :refresh_tokens, through: :users

  before_validation :ensure_slug

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[active suspended] }
  validates :support_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  private

  def ensure_slug
    return if slug.present? || name.blank?

    base = name.to_s.parameterize
    candidate = base
    suffix = 2

    while self.class.where(slug: candidate).exists?
      candidate = "#{base}-#{suffix}"
      suffix += 1
    end

    self.slug = candidate
  end
end
