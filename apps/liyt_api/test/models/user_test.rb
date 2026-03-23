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

  test "email is unique across businesses" do
    other_business = businesses(:two)

    duplicate = User.new(
      business: other_business,
      email: users(:one).email.upcase,
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

  test "tracks created and revoked api keys" do
    user = users(:one)

    assert_includes user.created_api_keys, api_keys(:active)
    assert_includes user.created_api_keys, api_keys(:revoked)
    assert_includes user.revoked_api_keys, api_keys(:revoked)
  end
end
