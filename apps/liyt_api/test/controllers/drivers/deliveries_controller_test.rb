require "test_helper"

class Drivers::DeliveriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @driver = drivers(:one)
    @token = Infra::Jwt.encode({ "sub" => @driver.id, "typ" => "driver" })
  end

  test "lists available deliveries" do
    get drivers_deliveries_path, headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert body.is_a?(Array)
  end

  test "rejects malformed authorization headers when listing available deliveries" do
    [ "Bearer ", "Bearer", "Token abc123", "Bearer invalid.jwt" ].each do |header|
      get drivers_deliveries_path, headers: { "Authorization" => header }

      assert_response :unauthorized
    end
  end

  test "accepts a delivery" do
    delivery = deliveries(:pending)

    patch accept_drivers_delivery_path(delivery),
      headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "accepted", body["status"]
    assert_equal @driver.id, body["driver_id"].to_i
    delivery.reload
    assert delivery.accepted_at.present?
    assert_equal @driver.id, delivery.driver_id
  end

  test "marks delivery as picked up" do
    delivery = deliveries(:accepted)
    delivery.update!(driver: @driver)

    patch pickup_drivers_delivery_path(delivery),
      headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "picked_up", body["status"]
    delivery.reload
    assert delivery.picked_up_at.present?
  end

  test "completes a delivery" do
    delivery = deliveries(:accepted)
    delivery.update!(driver: @driver, status: :picked_up)

    patch complete_drivers_delivery_path(delivery),
      headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "delivered", body["status"]
    delivery.reload
    assert delivery.delivered_at.present?
  end

  test "rejects accepting already assigned delivery" do
    other_driver = drivers(:one)
    delivery = deliveries(:accepted)
    delivery.update!(driver: other_driver)

    patch accept_drivers_delivery_path(delivery),
      headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :unprocessable_entity
  end

  test "forbids pickup for a delivery assigned to another driver" do
    other_driver = Driver.create!(
      email: "other-driver@example.com",
      phone: "+251911000999",
      password: "password",
      password_confirmation: "password"
    )
    delivery = deliveries(:accepted)
    delivery.update!(driver: other_driver)

    patch pickup_drivers_delivery_path(delivery),
      headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :forbidden
    body = JSON.parse(response.body)
    assert_equal "not_assigned_to_you", body["error"]
  end

  test "lists driver delivery history" do
    get history_drivers_deliveries_path, headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert body["data"].is_a?(Array)
    assert body["meta"].is_a?(Hash)
    # Ensure delivered fixture is present
    ids = body["data"].map { |d| d["public_id"] }
    assert_includes ids, deliveries(:delivered).public_id
  end

  test "filters history by status and paginates" do
    # Only delivered
    get history_drivers_deliveries_path(status: "delivered", per_page: 1, page: 1), headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 1, body["data"].length
    assert_equal 1, body["meta"]["per_page"]
    assert_equal 1, body["meta"]["page"]
    assert body["meta"]["total_count"] >= 1
    assert_equal "delivered", body["data"].first["status"]
  end
end
