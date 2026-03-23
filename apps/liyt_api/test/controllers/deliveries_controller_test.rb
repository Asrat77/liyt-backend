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

    @active_api_key = "a1b2c3d4e5f6.active-secret"
    @expired_api_key = "b1c2d3e4f5a6.expired-secret"
    @revoked_api_key = "c1d2e3f4a5b6.revoked-secret"
  end

  test "lists business deliveries" do
    get deliveries_path, headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert body.is_a?(Array)
  end

  test "uses jwt auth for non-create endpoint when x-api-key header is also present" do
    get deliveries_path,
      headers: {
        "Authorization" => "Bearer #{@token}",
        "X-API-Key" => "nope.not-a-real-key"
      }

    assert_response :ok
    body = JSON.parse(response.body)
    assert body.is_a?(Array)
  end

  test "creates a delivery" do
    assert_difference("Delivery.count") do
      post deliveries_path,
        headers: { "Authorization" => "Bearer #{@token}" },
        params: delivery_create_params
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Test delivery", body["description"]
    assert_equal 150.0, body["price"].to_f
    assert_equal "awaiting_recipient", body["status"]
    assert body["public_id"].present?
    assert body["stops"].present?
    assert body["items"].present?
  end

  test "creates a delivery with active api key and scope" do
    assert_difference("Delivery.count") do
      post deliveries_path,
        headers: api_key_header(@active_api_key),
        params: delivery_create_params
    end

    assert_response :created
    body = JSON.parse(response.body)

    assert_equal users(:one).business_id, body["business_id"]
    assert_equal "Test delivery", body["description"]

    delivery = Delivery.find_by!(public_id: body["public_id"])
    created_event = delivery.delivery_events.find_by!(event_type: "created")
    assert_equal "ApiKey", created_event.actor_type
    assert_equal api_keys(:active).id, created_event.actor_id
  end

  test "creates a delivery with business defaults when pickup is omitted" do
    BusinessSetting.create!(
      business: @business,
      pickup_address1: "Default Pickup St",
      pickup_city: "Addis Ababa",
      pickup_region: "Addis Ababa",
      pickup_country_code: "ET",
      pickup_contact_name: "Default Sender",
      pickup_contact_phone: "+251900000000",
      pickup_instructions: "Ring back door"
    )

    params = delivery_create_params.except(:pickup)

    assert_difference("Delivery.count") do
      post deliveries_path,
        headers: api_key_header(@active_api_key),
        params: params
    end

    assert_response :created
    body = JSON.parse(response.body)
    pickup = body["stops"].find { |stop| stop["kind"] == "pickup" }

    assert_equal "Default Pickup St", pickup["address1"]
    assert_equal "Default Sender", pickup["contact_name"]
    assert_equal "Ring back door", pickup["instructions"]
  end

  test "uses request pickup values over defaults" do
    BusinessSetting.create!(
      business: @business,
      pickup_address1: "Default Pickup St",
      pickup_city: "Addis Ababa",
      pickup_region: "Addis Ababa",
      pickup_country_code: "ET",
      pickup_contact_name: "Default Sender",
      pickup_contact_phone: "+251900000000",
      pickup_instructions: "Default instructions"
    )

    params = delivery_create_params
    params[:pickup][:address1] = "Request Pickup St"
    params[:pickup][:contact_name] = "Request Sender"

    post deliveries_path,
      headers: api_key_header(@active_api_key),
      params: params

    assert_response :created
    body = JSON.parse(response.body)
    pickup = body["stops"].find { |stop| stop["kind"] == "pickup" }

    assert_equal "Request Pickup St", pickup["address1"]
    assert_equal "Request Sender", pickup["contact_name"]
    assert_equal "Default instructions", pickup["instructions"]
  end

  test "creates a delivery by merging partial pickup with defaults" do
    BusinessSetting.create!(
      business: @business,
      pickup_address1: "Default Pickup St",
      pickup_city: "Addis Ababa",
      pickup_region: "Addis Ababa",
      pickup_country_code: "ET",
      pickup_contact_name: "Default Sender",
      pickup_contact_phone: "+251900000000"
    )

    params = delivery_create_params
    params[:pickup] = { address1: "Partial Pickup St" }

    post deliveries_path,
      headers: api_key_header(@active_api_key),
      params: params

    assert_response :created
    body = JSON.parse(response.body)
    pickup = body["stops"].find { |stop| stop["kind"] == "pickup" }

    assert_equal "Partial Pickup St", pickup["address1"]
    assert_equal "Addis Ababa", pickup["city"]
    assert_equal "+251900000000", pickup["contact_phone"]
  end

  test "returns unprocessable entity when pickup is unresolved and defaults are missing" do
    params = delivery_create_params.except(:pickup)

    assert_no_difference("Delivery.count") do
      post deliveries_path,
        headers: api_key_header(@active_api_key),
        params: params
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)

    assert_equal "pickup_invalid", body["error"]
  end

  test "returns unauthorized when api key is missing for delivery create" do
    post deliveries_path, params: delivery_create_params

    assert_response :unauthorized
  end

  test "returns unauthorized for invalid api key" do
    post deliveries_path,
      headers: api_key_header("nope.not-a-real-key"),
      params: delivery_create_params

    assert_response :unauthorized
  end

  test "returns unauthorized for revoked api key" do
    post deliveries_path,
      headers: api_key_header(@revoked_api_key),
      params: delivery_create_params

    assert_response :unauthorized
  end

  test "returns unauthorized for expired api key" do
    post deliveries_path,
      headers: api_key_header(@expired_api_key),
      params: delivery_create_params

    assert_response :unauthorized
  end

  test "returns forbidden when api key does not include deliveries:write scope" do
    narrow_key = ApiKey.create!(
      business: @business,
      created_by_user: @user,
      name: "Read Only",
      scopes: [ "deliveries:read" ]
    )

    post deliveries_path,
      headers: api_key_header(narrow_key.plaintext_key),
      params: delivery_create_params

    assert_response :forbidden
  end

  test "uses api key tenant context when api key and jwt are both provided" do
    cross_tenant_user = users(:two)
    cross_tenant_token = Infra::Jwt.encode({
      "sub" => cross_tenant_user.id,
      "biz" => cross_tenant_user.business_id,
      "typ" => "user"
    })

    assert_difference("Delivery.count") do
      post deliveries_path,
        headers: api_key_header(@active_api_key).merge("Authorization" => "Bearer #{cross_tenant_token}"),
        params: delivery_create_params
    end

    assert_response :created
    body = JSON.parse(response.body)

    assert_equal users(:one).business_id, body["business_id"]
    refute_equal cross_tenant_user.business_id, body["business_id"]
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

  private

  def api_key_header(raw_key)
    { "X-API-Key" => raw_key }
  end

  def delivery_create_params
    {
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
end
