require "test_helper"

class BusinessLocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @staff = users(:two)
    @admin_token = Infra::Jwt.encode({ "sub" => @admin.id, "biz" => @admin.business_id })
    @staff_token = Infra::Jwt.encode({ "sub" => @staff.id, "biz" => @staff.business_id })
    @location = business_locations(:one)
  end

  test "lists business locations for the current tenant" do
    get business_locations_path, headers: auth_header(@admin_token)

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal 1, body.length
    assert_equal @location.id, body.first["id"]
  end

  test "rejects malformed authorization headers when listing locations" do
    [ "Bearer ", "Bearer", "Token abc123", "Bearer invalid.jwt" ].each do |header|
      get business_locations_path, headers: { "Authorization" => header }

      assert_response :unauthorized
    end
  end

  test "creates a business location for admins" do
    post business_locations_path,
      params: { name: "New Depot", country_code: "US" },
      headers: auth_header(@admin_token)

    assert_response :created
    body = JSON.parse(response.body)

    assert_equal "New Depot", body["name"]
    assert_equal @admin.business_id, body["business_id"]
  end

  test "forbids create for non-admins" do
    post business_locations_path,
      params: { name: "Nope", country_code: "US" },
      headers: auth_header(@staff_token)

    assert_response :forbidden
  end

  test "shows a business location" do
    get business_location_path(@location), headers: auth_header(@admin_token)

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal @location.id, body["id"]
  end

  test "prevents access to other tenant locations" do
    get business_location_path(@location), headers: auth_header(@staff_token)

    assert_response :not_found
  end

  test "returns not found when other tenant admin updates a location" do
    cross_tenant_admin_role = Role.create!(business: @staff.business, name: "admin")
    UserRole.create!(user: @staff, role: cross_tenant_admin_role)

    patch business_location_path(@location),
      params: { city: "Nope" },
      headers: auth_header(@staff_token)

    assert_response :not_found
  end

  test "updates a business location for admins" do
    patch business_location_path(@location),
      params: { city: "Updated" },
      headers: auth_header(@admin_token)

    assert_response :ok
    assert_equal "Updated", @location.reload.city
  end

  test "destroys a business location for admins" do
    assert_difference -> { BusinessLocation.count }, -1 do
      delete business_location_path(@location), headers: auth_header(@admin_token)
    end

    assert_response :no_content
  end

  private

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
