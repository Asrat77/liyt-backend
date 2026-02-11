class RefreshToken < ApplicationRecord
  belongs_to :owner, polymorphic: true

  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  validates :token_hash, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :family, presence: true

  def revoke!(time = Time.current)
    update!(revoked_at: time)
  end

  def revoke_family!(time = Time.current)
    self.class.where(owner: owner, family: family).update_all(revoked_at: time)
  end

  def expired?
    expires_at <= Time.current
  end

  def revoked?
    revoked_at.present?
  end
end
