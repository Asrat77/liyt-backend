require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "requires name and business" do
    role = Role.new

    assert_not role.valid?
    assert_includes role.errors[:name], "can't be blank"
    assert_includes role.errors[:business], "must exist"
  end

  test "name is unique per business" do
    duplicate = Role.new(business: businesses(:one), name: roles(:admin).name)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end
end
