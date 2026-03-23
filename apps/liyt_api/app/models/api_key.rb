class ApiKey < ApplicationRecord
  belongs_to :business
  belongs_to :created_by_user, class_name: "User", optional: true
  belongs_to :revoked_by_user, class_name: "User", optional: true

  attr_reader :plaintext_key

  scope :active, -> { where(revoked_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  before_validation :normalize_scopes
  before_validation :ensure_key_material, on: :create

  validates :name, presence: true
  validates :prefix, presence: true, uniqueness: true
  validates :key_hash, presence: true, uniqueness: true
  validates :scopes, presence: true
  validate :scopes_must_be_non_blank_strings

  def active?
    !revoked? && !expired?
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def allows_scope?(scope)
    scopes.include?(scope.to_s)
  end

  def reload(*)
    super.tap { remove_instance_variable(:@plaintext_key) if instance_variable_defined?(:@plaintext_key) }
  end

  private

  def normalize_scopes
    return if scopes.nil?

    self.scopes = scopes.map { |scope| scope.is_a?(String) ? scope.strip : scope }
  end

  def ensure_key_material
    return if prefix.present? && key_hash.present?

    @plaintext_key = Infra::TokenGenerator.generate
    self.prefix ||= plaintext_key.first(12)
    self.key_hash ||= Infra::TokenHashing.digest(plaintext_key)
  end

  def scopes_must_be_non_blank_strings
    return if scopes.is_a?(Array) && scopes.all? { |scope| scope.is_a?(String) && scope.present? }

    errors.add(:scopes, "must be an array of non-blank strings")
  end
end
