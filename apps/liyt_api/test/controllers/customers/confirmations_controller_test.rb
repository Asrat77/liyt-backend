require "test_helper"

class Customers::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "returns not found when showing an unknown confirmation token" do
    get customers_confirmation_path, params: { token: "missing-token" }

    assert_response :not_found
  end

  test "returns gone when confirming with an expired token" do
    post customers_confirmation_confirm_path, params: {
      token: delivery_tracking_tokens(:token_expired).token_hash,
      full_name: "Expired Token",
      phone: "+251933333000"
    }

    assert_response :gone
  end

  test "returns not found when confirming with an unknown token" do
    post customers_confirmation_confirm_path, params: {
      token: "missing-token",
      full_name: "Unknown Token",
      phone: "+251933333001"
    }

    assert_response :not_found
  end

  test "confirms delivery with sign-in params and provisions customer user role" do
    delivery = deliveries(:awaiting_recipient)

    assert_difference [ "User.count", "UserRole.count" ], 1 do
      post customers_confirmation_confirm_path, params: {
        token: delivery_tracking_tokens(:token_one).token_hash,
        full_name: "Customer Signin",
        phone: "+251933333333",
        email: "customer-signin@example.com",
        password: "password"
      }
    end

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal "Delivery confirmed successfully", body["message"]
    assert_equal "pending", delivery.reload.status

    user = User.find_by(email: "customer-signin@example.com")
    assert_not_nil user
    assert user.authenticate("password")

    role = Role.find_by(business_id: delivery.business_id, name: "customer")
    assert_not_nil role
    assert UserRole.exists?(user: user, role: role)
  end

  test "confirms delivery without password and preserves legacy confirmation behavior" do
    delivery = deliveries(:awaiting_recipient)

    assert_no_difference [ "User.count", "Role.count", "UserRole.count" ] do
      post customers_confirmation_confirm_path, params: {
        token: delivery_tracking_tokens(:token_one).token_hash,
        full_name: "Legacy Customer",
        phone: "+251944444444",
        email: "legacy-customer@example.com"
      }
    end

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal "Delivery confirmed successfully", body["message"]
    assert_equal "pending", delivery.reload.status

    customer = Customer.find_by(email: "legacy-customer@example.com")
    assert_not_nil customer
    assert_equal "Legacy Customer", customer.full_name
  end

  test "duplicate confirmation submit returns already confirmed and does not duplicate records" do
    delivery = deliveries(:awaiting_recipient)
    params = {
      token: delivery_tracking_tokens(:token_one).token_hash,
      full_name: "Customer Signin",
      phone: "+251933333333",
      email: "duplicate-submit@example.com",
      password: "password"
    }

    post customers_confirmation_confirm_path, params: params
    assert_response :ok

    assert_no_difference [ "User.count", "Customer.count", "Role.count", "UserRole.count", "DeliveryEvent.count" ] do
      post customers_confirmation_confirm_path, params: params
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_equal "already_confirmed", body["error"]

    assert_equal "pending", delivery.reload.status
  end
end
