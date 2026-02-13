require "test_helper"

class Auth::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "registers a business and admin user" do
    post auth_registrations_path, params: {
      business_name: "Gamma Dispatch",
      email: "admin@gamma.test",
      password: "password",
      support_email: "support@gamma.test",
      status: "suspended"
    }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_equal "Bearer", body["token_type"]
    assert body["expires_in"].positive?
    assert_equal "admin@gamma.test", body.dig("user", "email")
    assert_equal "Gamma Dispatch", body.dig("business", "name")
    assert body.dig("business", "slug").present?
    assert_equal "active", body.dig("business", "status")
    assert_equal "support@gamma.test", body.dig("business", "support_email")
    assert_includes body["roles"], "admin"
  end

  test "returns validation errors for invalid registration" do
    post auth_registrations_path, params: {
      business_name: "",
      email: "",
      password: "",
      support_email: ""
    }

    assert_response :unprocessable_entity
  end

  test "rejects duplicate email" do
    post auth_registrations_path, params: {
      business_name: "Delta Dispatch",
      email: users(:one).email,
      password: "password"
    }

    assert_response :unprocessable_entity
  end
end
