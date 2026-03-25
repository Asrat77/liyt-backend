require "test_helper"

class BusinessSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @other_tenant_user = users(:two)

    @admin_token = Infra::Jwt.encode({ "sub" => @admin.id, "biz" => @admin.business_id, "typ" => "user" })

    @staff = User.create!(
      business: @admin.business,
      email: "settings-staff@acme.test",
      password: "password",
      password_confirmation: "password"
    )
    @staff.roles << Role.find_or_create_by!(business: @admin.business, name: "staff")
    @staff_token = Infra::Jwt.encode({ "sub" => @staff.id, "biz" => @staff.business_id, "typ" => "user" })
  end

  test "shows current tenant business settings" do
    setting = BusinessSetting.find_or_initialize_by(business: @admin.business)
    setting.update!(
      pickup_address1: "HQ Pickup",
      pickup_city: "Addis Ababa",
      pickup_region: "Addis Ababa",
      pickup_country_code: "ET",
      pickup_contact_name: "Ops Desk",
      pickup_contact_phone: "+251911111111",
      pickup_instructions: "Call on arrival"
    )

    get business_settings_path, headers: auth_header(@admin_token)

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal @admin.business_id, body["business_id"]
    assert_equal "HQ Pickup", body["pickup_address1"]
    assert_equal "Ops Desk", body["pickup_contact_name"]
  end

  test "staff can read business settings" do
    get business_settings_path, headers: auth_header(@staff_token)

    assert_response :ok
  end

  test "admin updates current tenant defaults" do
    patch business_settings_path,
      headers: auth_header(@admin_token),
      params: {
        pickup_address1: "Warehouse 9",
        pickup_city: "Adama",
        pickup_region: "Oromia",
        pickup_country_code: "ET",
        pickup_contact_name: "Dispatch",
        pickup_contact_phone: "+251922222222",
        pickup_instructions: "Use loading bay"
      }

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal "Warehouse 9", body["pickup_address1"]
    assert_equal "Dispatch", body["pickup_contact_name"]
    assert_equal @admin.business_id, body["business_id"]
  end

  test "forbids settings updates for non-admin users" do
    patch business_settings_path,
      headers: auth_header(@staff_token),
      params: { pickup_address1: "Forbidden" }

    assert_response :forbidden
  end

  test "settings updates are tenant safe" do
    other_setting = BusinessSetting.find_or_initialize_by(business: @other_tenant_user.business)
    other_setting.update!(
      pickup_address1: "Other Tenant Pickup",
      pickup_city: "Gondar",
      pickup_region: "Amhara",
      pickup_country_code: "ET",
      pickup_contact_name: "Other Ops",
      pickup_contact_phone: "+251933333333"
    )

    patch business_settings_path,
      headers: auth_header(@admin_token),
      params: {
        pickup_address1: "Acme Pickup",
        pickup_city: "Addis Ababa",
        pickup_region: "Addis Ababa",
        pickup_country_code: "ET",
        pickup_contact_name: "Acme Ops",
        pickup_contact_phone: "+251944444444"
      }

    assert_response :ok
    assert_equal "Other Tenant Pickup", other_setting.reload.pickup_address1
  end

  private

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
