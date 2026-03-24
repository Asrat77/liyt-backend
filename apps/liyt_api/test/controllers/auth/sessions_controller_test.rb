require "test_helper"

class Auth::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "creates a session with valid credentials" do
    post auth_sessions_path,
      params: { email: @user.email, password: "password" }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_equal "Bearer", body["token_type"]
    assert body["expires_in"].positive?
  end

  test "rejects invalid credentials" do
    post auth_sessions_path,
      params: { email: @user.email, password: "wrong" }

    assert_response :unauthorized
  end

  test "rejects missing refresh token" do
    post refresh_auth_sessions_path

    assert_response :unauthorized
  end

  test "refreshes session with a valid refresh token" do
    post refresh_auth_sessions_path, params: { refresh_token: "token-active" }

    assert_response :ok
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert refresh_tokens(:active).reload.last_used_at.present?
    assert refresh_tokens(:active).reload.revoked?
  end

  test "rejects refresh with expired token" do
    post refresh_auth_sessions_path, params: { refresh_token: "token-expired" }

    assert_response :unauthorized
    assert refresh_tokens(:expired).reload.revoked?
  end

  test "revokes a refresh token" do
    post revoke_auth_sessions_path, params: { refresh_token: "token-active" }

    assert_response :no_content
    assert refresh_tokens(:active).reload.revoked?
  end

  test "returns not found when revoking an unknown token" do
    post revoke_auth_sessions_path, params: { refresh_token: "missing" }

    assert_response :not_found
  end

  test "does not require auth for health check" do
    get rails_health_check_path

    assert_response :ok
  end

  test "rejects access to auth me without token" do
    get auth_me_path

    assert_response :unauthorized
  end

  test "customer provisioned via confirmation can sign in and refresh with customer role" do
    password = "password"
    email = "confirmed-customer@example.com"

    assert_difference [ "User.count", "Role.count", "UserRole.count" ], 1 do
      post customers_confirmation_confirm_path, params: {
        token: delivery_tracking_tokens(:token_one).token_hash,
        full_name: "Confirmed Customer",
        phone: "+251955555555",
        email: email,
        password: password
      }
    end

    assert_response :ok

    post auth_sessions_path, params: { email: email, password: password }

    assert_response :created
    signin_body = JSON.parse(response.body)
    assert signin_body["access_token"].present?
    assert signin_body["refresh_token"].present?
    signin_payload = Infra::Jwt.decode(signin_body["access_token"])
    assert_includes signin_payload["role"], "customer"

    post refresh_auth_sessions_path, params: { refresh_token: signin_body["refresh_token"] }

    assert_response :ok
    refresh_body = JSON.parse(response.body)
    refresh_payload = Infra::Jwt.decode(refresh_body["access_token"])
    assert_includes refresh_payload["role"], "customer"
    assert_includes refresh_body["roles"], "customer"
  end
end
