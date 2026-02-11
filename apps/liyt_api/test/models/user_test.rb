require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires email and password" do
    user = User.new(business: businesses(:one))

    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
    assert_includes user.errors[:password_digest], "can't be blank"
  end

  test "email is unique per business" do
    duplicate = User.new(
      business: businesses(:one),
      email: users(:one).email,
      password: "password"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "password authentication works" do
    user = users(:one)

    assert user.authenticate("password")
    assert_not user.authenticate("wrong")
  end

  test "role helpers reflect assigned roles" do
    user = users(:one)

    assert user.admin?
    assert_not user.staff?
  end
end
