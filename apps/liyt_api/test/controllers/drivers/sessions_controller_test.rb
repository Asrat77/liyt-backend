require "test_helper"

class Drivers::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @driver = drivers(:one)
  end

  test "creates a driver session with valid credentials" do
    post drivers_sessions_path, params: { email: @driver.email, password: "password" }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_equal "Bearer", body["token_type"]
  end

  test "rejects invalid credentials" do
    post drivers_sessions_path, params: { email: @driver.email, password: "wrong" }

    assert_response :unauthorized
  end

  test "refreshes session with a valid refresh token" do
    post refresh_drivers_sessions_path, params: { refresh_token: "token-driver" }

    assert_response :ok
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert refresh_tokens(:driver_active).reload.last_used_at.present?
    assert refresh_tokens(:driver_active).reload.revoked?
  end

  test "rejects replayed refresh token" do
    post refresh_drivers_sessions_path, params: { refresh_token: "token-driver" }
    assert_response :ok

    post refresh_drivers_sessions_path, params: { refresh_token: "token-driver" }
    assert_response :unauthorized
  end

  test "rejects refresh token owned by a user" do
    post refresh_drivers_sessions_path, params: { refresh_token: "token-active" }

    assert_response :unauthorized
  end
end
