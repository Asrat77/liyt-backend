require "test_helper"

class BusinessSettingTest < ActiveSupport::TestCase
  test "belongs to business" do
    setting = BusinessSetting.new

    assert_not setting.valid?
    assert_includes setting.errors[:business], "must exist"
  end

  test "business has only one settings row" do
    business = businesses(:one)
    BusinessSetting.create!(business: business)

    duplicate = BusinessSetting.new(business: business)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:business_id], "has already been taken"
  end
end
