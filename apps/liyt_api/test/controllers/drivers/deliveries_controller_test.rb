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

  test "accepts a delivery" do
    delivery = deliveries(:pending)

    patch accept_drivers_delivery_path(delivery),
      headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "accepted", body["status"]
    assert_equal @driver.id, body["driver_id"]
    delivery.reload
    assert delivery.accepted_at.present?
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
end
