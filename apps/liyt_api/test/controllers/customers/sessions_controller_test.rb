require "test_helper"

class Customers::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:customer_one)
  end

  test "creates a customer session with valid credentials" do
    post customers_sessions_path, params: { email: @customer.email, password: "password" }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_equal "Bearer", body["token_type"]
  end

  test "rejects valid user without customer role" do
    post customers_sessions_path, params: { email: users(:one).email, password: "password" }

    assert_response :unauthorized
  end

  test "refreshes customer session and includes roles" do
    post refresh_customers_sessions_path, params: { refresh_token: "token-customer" }

    assert_response :ok
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_includes body["roles"], "customer"
    assert refresh_tokens(:customer_active).reload.last_used_at.present?
    assert refresh_tokens(:customer_active).reload.revoked?
  end

  test "rejects refresh for non-customer user token" do
    post refresh_customers_sessions_path, params: { refresh_token: "token-active" }

    assert_response :unauthorized
  end

  test "rejects refresh for driver token" do
    post refresh_customers_sessions_path, params: { refresh_token: "token-driver" }

    assert_response :unauthorized
  end

  test "revokes customer refresh token" do
    post revoke_customers_sessions_path, params: { refresh_token: "token-customer" }

    assert_response :no_content
    assert refresh_tokens(:customer_active).reload.revoked?
  end

  test "returns not found when revoking non-customer user token" do
    post revoke_customers_sessions_path, params: { refresh_token: "token-active" }

    assert_response :not_found
  end

  test "returns not found when revoking driver token" do
    post revoke_customers_sessions_path, params: { refresh_token: "token-driver" }

    assert_response :not_found
  end
end
