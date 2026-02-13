require "test_helper"

class BusinessLocationTest < ActiveSupport::TestCase
  test "requires a business, name, and country code" do
    location = BusinessLocation.new

    assert_not location.valid?
    assert_includes location.errors[:business], "must exist"
    assert_includes location.errors[:name], "can't be blank"
    assert_includes location.errors[:country_code], "can't be blank"
  end

  test "latitude and longitude are within bounds" do
    location = BusinessLocation.new(
      business: businesses(:one),
      name: "Test",
      country_code: "US",
      latitude: 120,
      longitude: -200
    )

    assert_not location.valid?
    assert_includes location.errors[:latitude], "must be less than or equal to 90"
    assert_includes location.errors[:longitude], "must be greater than or equal to -180"
  end
end
