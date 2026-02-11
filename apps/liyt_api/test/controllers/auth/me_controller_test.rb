require "test_helper"

class Auth::MeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = Infra::Jwt.encode({ "sub" => @user.id, "biz" => @user.business_id })
  end

  test "returns current user info with a valid token" do
    get auth_me_path, headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal @user.id, body["id"]
    assert_equal @user.email, body["email"]
    assert_equal @user.business_id, body["business_id"]
    assert_includes body["roles"], "admin"
  end

  test "rejects invalid tokens" do
    get auth_me_path, headers: { "Authorization" => "Bearer bad.token" }

    assert_response :unauthorized
  end
end
