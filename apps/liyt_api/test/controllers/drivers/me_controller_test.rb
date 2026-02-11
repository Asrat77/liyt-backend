require "test_helper"

class Drivers::MeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @driver = drivers(:one)
    @token = Infra::Jwt.encode({ "sub" => @driver.id, "typ" => "driver" })
  end

  test "returns current driver info with a valid token" do
    get drivers_me_path, headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal @driver.id, body["id"]
    assert_equal @driver.email, body["email"]
  end

  test "rejects access without token" do
    get drivers_me_path

    assert_response :unauthorized
  end
end
