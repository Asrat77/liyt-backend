require "test_helper"

class DeliveriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = Infra::Jwt.encode({
      "sub" => @user.id,
      "biz" => @user.business_id,
      "role" => [ "admin" ],
      "typ" => "user"
    })
    @business = @user.business
  end

  test "lists business deliveries" do
    get deliveries_path, headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert body.is_a?(Array)
  end

  test "creates a delivery" do
    assert_difference("Delivery.count") do
      post deliveries_path,
        headers: { "Authorization" => "Bearer #{@token}" },
        params: {
          description: "Test delivery",
          price: 150.00,
          recipient_email: "customer@example.com",
          pickup: {
            address1: "123 Pickup St",
            city: "Addis Ababa",
            region: "Addis Ababa",
            country_code: "ET",
            contact_name: "Sender Name",
            contact_phone: "+251911111111"
          },
          items: [
            { name: "Package A", quantity: 2 },
            { name: "Package B", quantity: 1 }
          ]
        }
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Test delivery", body["description"]
    assert_equal 150.00, body["price"]
    assert_equal "awaiting_recipient", body["status"]
    assert body["public_id"].present?
    assert body["stops"].present?
    assert body["items"].present?
  end

  test "shows a delivery" do
    delivery = deliveries(:awaiting_recipient)
    delivery.update!(business: @business)

    get delivery_path(delivery), headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal delivery.public_id, body["public_id"]
  end

  test "cancels a delivery" do
    delivery = deliveries(:awaiting_recipient)
    delivery.update!(business: @business)

    patch cancel_delivery_path(delivery),
      headers: { "Authorization" => "Bearer #{@token}" },
      params: { reason: "Customer requested" }

    assert_response :no_content
    delivery.reload
    assert_equal "cancelled", delivery.status
    assert delivery.cancelled_at.present?
  end

  test "rejects cancellation for non-pending delivery" do
    delivery = deliveries(:accepted)
    delivery.update!(business: @business)

    patch cancel_delivery_path(delivery),
      headers: { "Authorization" => "Bearer #{@token}" },
      params: { reason: "Customer requested" }

    assert_response :unprocessable_entity
  end
end
