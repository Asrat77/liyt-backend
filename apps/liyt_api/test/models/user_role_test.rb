require "test_helper"

class UserRoleTest < ActiveSupport::TestCase
  test "requires a unique user-role pairing" do
    duplicate = UserRole.new(user: users(:one), role: roles(:admin))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:role_id], "has already been taken"
  end
end
