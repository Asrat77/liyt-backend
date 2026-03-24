require "test_helper"

class Customers::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "confirms delivery with sign-in params and provisions customer user role" do
    delivery = deliveries(:awaiting_recipient)

    assert_difference [ "User.count", "Role.count", "UserRole.count" ], 1 do
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
end