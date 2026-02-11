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
end
