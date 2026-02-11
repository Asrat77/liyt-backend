require "test_helper"

class DriverTest < ActiveSupport::TestCase
  test "requires email and password" do
    driver = Driver.new

    assert_not driver.valid?
    assert_includes driver.errors[:email], "can't be blank"
    assert_includes driver.errors[:password_digest], "can't be blank"
  end

  test "email is unique" do
    duplicate = Driver.new(
      email: drivers(:one).email,
      password: "password"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "password authentication works" do
    driver = drivers(:one)

    assert driver.authenticate("password")
    assert_not driver.authenticate("wrong")
  end
end
