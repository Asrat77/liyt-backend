require "test_helper"

class RefreshTokenTest < ActiveSupport::TestCase
  test "requires token hash and expires_at" do
    token = RefreshToken.new(owner: users(:one))

    assert_not token.valid?
    assert_includes token.errors[:token_hash], "can't be blank"
    assert_includes token.errors[:expires_at], "can't be blank"
  end

  test "active scope excludes expired or revoked tokens" do
    active = refresh_tokens(:active)
    expired = refresh_tokens(:expired)
    revoked = refresh_tokens(:revoked)

    assert_includes RefreshToken.active, active
    assert_not_includes RefreshToken.active, expired
    assert_not_includes RefreshToken.active, revoked
  end

  test "revoke sets revoked_at" do
    token = refresh_tokens(:active)

    token.revoke!

    assert token.revoked?
  end
end
