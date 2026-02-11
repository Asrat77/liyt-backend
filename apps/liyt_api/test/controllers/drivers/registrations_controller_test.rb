require "test_helper"

class Drivers::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "registers a driver" do
    post drivers_registrations_path, params: {
      email: "newdriver@ride.test",
      password: "password"
    }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_equal "newdriver@ride.test", body.dig("driver", "email")
  end

  test "rejects invalid registration" do
    post drivers_registrations_path, params: {
      email: "",
      password: ""
    }

    assert_response :unprocessable_entity
  end
end
