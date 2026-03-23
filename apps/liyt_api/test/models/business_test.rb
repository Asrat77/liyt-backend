require "test_helper"

class BusinessTest < ActiveSupport::TestCase
  test "requires a name and slug" do
    business = Business.new

    assert_not business.valid?
    assert_includes business.errors[:name], "can't be blank"
    assert_includes business.errors[:slug], "can't be blank"
  end

  test "slug is unique" do
    duplicate = Business.new(name: "Dup", slug: businesses(:one).slug)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "has api keys association" do
    assert_respond_to businesses(:one), :api_keys
  end
end
