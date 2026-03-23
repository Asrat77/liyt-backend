require "test_helper"

class ApiKeyTest < ActiveSupport::TestCase
  test "requires name and scopes while generating prefix and key_hash" do
    key = ApiKey.new(business: businesses(:one), scopes: nil)

    assert_not key.valid?
    assert_includes key.errors[:name], "can't be blank"
    assert_includes key.errors[:scopes], "can't be blank"
    assert_includes key.errors[:scopes], "must be an array of non-blank strings"
    assert key.prefix.present?
    assert key.key_hash.present?
    assert_empty key.errors[:prefix]
    assert_empty key.errors[:key_hash]
  end

  test "generates one-time plaintext key and persists only hash" do
    key = ApiKey.create!(
      business: businesses(:one),
      created_by_user: users(:one),
      name: "Orders API",
      scopes: [ "deliveries:write" ]
    )

    assert key.plaintext_key.present?
    assert_equal Infra::TokenHashing.digest(key.plaintext_key), key.key_hash
    assert_equal key.plaintext_key.first(12), key.prefix
    assert_nil key.reload.plaintext_key
  end

  test "enforces unique prefix and key hash" do
    duplicate = ApiKey.new(
      business: businesses(:one),
      name: "Duplicate",
      prefix: api_keys(:active).prefix,
      key_hash: api_keys(:active).key_hash,
      scopes: [ "deliveries:write" ]
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:prefix], "has already been taken"
    assert_includes duplicate.errors[:key_hash], "has already been taken"
  end

  test "scopes must be an array of non-blank strings" do
    key = ApiKey.new(
      business: businesses(:one),
      name: "Bad Scopes",
      prefix: "deadbeef1234",
      key_hash: Infra::TokenHashing.digest("deadbeef1234.bad"),
      scopes: [ "deliveries:write", "", 123 ]
    )

    assert_not key.valid?
    assert_includes key.errors[:scopes], "must be an array of non-blank strings"
  end

  test "active scope excludes expired and revoked keys" do
    assert_includes ApiKey.active, api_keys(:active)
    assert_not_includes ApiKey.active, api_keys(:expired)
    assert_not_includes ApiKey.active, api_keys(:revoked)
  end

  test "non-expiring key is active when not revoked" do
    key = ApiKey.create!(
      business: businesses(:one),
      name: "Long Lived Integration",
      scopes: [ "deliveries:write" ],
      expires_at: nil
    )

    assert_includes ApiKey.active, key
    assert key.active?
    assert_not key.expired?
  end

  test "predicates and scope checks reflect current key state" do
    assert api_keys(:active).active?
    assert_not api_keys(:active).revoked?
    assert_not api_keys(:active).expired?
    assert api_keys(:active).allows_scope?("deliveries:write")
    assert_not api_keys(:active).allows_scope?("deliveries:read")

    assert api_keys(:expired).expired?
    assert_not api_keys(:expired).active?

    assert api_keys(:revoked).revoked?
    assert_not api_keys(:revoked).active?
  end

  test "associations are wired to business and user audit actors" do
    key = api_keys(:revoked)

    assert_equal businesses(:one), key.business
    assert_equal users(:one), key.created_by_user
    assert_equal users(:one), key.revoked_by_user
  end

  test "audit user associations are optional" do
    key = ApiKey.create!(
      business: businesses(:one),
      name: "System Generated",
      scopes: [ "deliveries:write" ]
    )

    assert_nil key.created_by_user
    assert_nil key.revoked_by_user
  end
end
