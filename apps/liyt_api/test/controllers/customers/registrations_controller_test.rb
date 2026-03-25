require "test_helper"

class Customers::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "registers a customer account and assigns customer role" do
    assigned_business = Business.find_by(status: "active") || Business.order(:id).first

    post customers_registrations_path, params: {
      email: "new-customer@acme.test",
      password: "password",
      full_name: "New Customer",
      phone: "+251911111111"
    }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_equal "Bearer", body["token_type"]
    assert_includes body["roles"], "customer"
    assert_equal "new-customer@acme.test", body.dig("user", "email")
    assert_equal assigned_business.id, body.dig("user", "business_id")

    user = User.find_by(email: "new-customer@acme.test")
    assert_not_nil user

    customer = Customer.find_by(email: "new-customer@acme.test")
    assert_not_nil customer
    assert_equal "New Customer", customer.full_name
    assert_equal "+251911111111", customer.phone

    role = Role.find_by(business_id: assigned_business.id, name: "customer")
    assert_not_nil role
    assert UserRole.exists?(user: user, role: role)
  end

  test "returns registration_invalid for invalid payload" do
    post customers_registrations_path, params: {
      email: "",
      password: ""
    }

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)

    assert_equal "registration_invalid", body["error"]
  end
end
