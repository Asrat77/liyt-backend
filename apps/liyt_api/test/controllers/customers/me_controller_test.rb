require "test_helper"

class Customers::MeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:customer_one)
    @customer_profile = Customer.create!(
      email: @customer.email,
      full_name: "Customer One",
      phone: "+251911223344",
      status: "active"
    )

    @customer_token = Infra::Jwt.encode({ "sub" => @customer.id, "biz" => @customer.business_id, "typ" => "user" })

    @non_customer = users(:one)
    @non_customer_token = Infra::Jwt.encode({ "sub" => @non_customer.id, "biz" => @non_customer.business_id, "typ" => "user" })
  end

  test "returns current customer profile" do
    get customers_me_path, headers: { "Authorization" => "Bearer #{@customer_token}" }

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal @customer.id, body["id"]
    assert_equal @customer.email, body["email"]
    assert_equal @customer_profile.full_name, body["full_name"]
    assert_equal @customer_profile.phone, body["phone"]
    assert_equal @customer.business_id, body["business_id"]
    assert_includes body["roles"], "customer"
  end

  test "rejects access without token" do
    get customers_me_path

    assert_response :unauthorized
  end

  test "rejects non-customer user token" do
    get customers_me_path, headers: { "Authorization" => "Bearer #{@non_customer_token}" }

    assert_response :unauthorized
  end
end
