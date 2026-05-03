require "test_helper"

class Customers::DeliveriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:customer_one)
    @token = Infra::Jwt.encode({ "sub" => @user.id, "biz" => @user.business_id, "typ" => "user" })
  end

  test "lists deliveries for customer" do
    get customers_deliveries_path, headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert body.is_a?(Array)
  end

  test "shows single delivery" do
    delivery = deliveries(:delivered)

    get customers_delivery_path(delivery), headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal delivery.public_id, body["public_id"]
  end

  test "returns not found for delivery belonging to other customer" do
    delivery = deliveries(:pending)

    get customers_delivery_path(delivery), headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :not_found
  end

  test "lists customer delivery history" do
    get history_customers_deliveries_path, headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert body["data"].is_a?(Array)
    assert body["meta"].is_a?(Hash)
    assert body["meta"]["total_count"] >= 1
  end

  test "filters history by status" do
    get history_customers_deliveries_path(status: "delivered"), headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 1, body["data"].length
    assert_equal "delivered", body["data"].first["status"]
  end

  test "paginates history" do
    get history_customers_deliveries_path(per_page: 1, page: 1), headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 1, body["data"].length
    assert_equal 1, body["meta"]["per_page"]
    assert_equal 1, body["meta"]["page"]
  end

  test "rejects unauthorized request" do
    get history_customers_deliveries_path

    assert_response :unauthorized
  end

  test "rejects non-customer role" do
    non_customer = users(:one)
    token = Infra::Jwt.encode({ "sub" => non_customer.id, "biz" => non_customer.business_id, "typ" => "user" })

    get history_customers_deliveries_path, headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :unauthorized
  end
end
