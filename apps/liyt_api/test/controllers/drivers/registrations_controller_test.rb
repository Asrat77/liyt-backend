require "test_helper"

class Drivers::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "registers a driver" do
    post drivers_registrations_path, params: {
      email: "newdriver@ride.test",
      password: "password",
      full_name: "Sam Rider",
      phone: "+251911111111",
      vehicle_type: "motorbike",
      license_number: "LIC-123"
    }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["access_token"].present?
    assert body["refresh_token"].present?
    assert_equal "newdriver@ride.test", body.dig("driver", "email")
    assert_equal "Sam Rider", body.dig("driver", "full_name")
    assert_equal "+251911111111", body.dig("driver", "phone")
    assert_equal "active", body.dig("driver", "status")
    assert_equal "motorbike", body.dig("driver", "vehicle_type")
    assert_equal "LIC-123", body.dig("driver", "license_number")
  end

  test "rejects invalid registration" do
    post drivers_registrations_path, params: {
      email: "",
      password: "",
      phone: ""
    }

    assert_response :unprocessable_entity
  end
end
