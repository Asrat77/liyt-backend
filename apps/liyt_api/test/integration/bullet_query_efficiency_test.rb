require "test_helper"

class BulletQueryEfficiencyTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @other_tenant_user = users(:two)
    @admin_token = Infra::Jwt.encode({ "sub" => @admin.id, "biz" => @admin.business_id, "typ" => "user" })
  end

  test "deliveries index avoids bullet n+1 regressions" do
    tenant_delivery = Delivery.create!(
      business: @admin.business,
      public_id: "BULLET-DEL-001",
      status: :awaiting_recipient,
      price: 99.0,
      description: "Bullet tenant delivery"
    )
    other_tenant_delivery = Delivery.create!(
      business: @other_tenant_user.business,
      public_id: "BULLET-DEL-OTHER-001",
      status: :awaiting_recipient,
      price: 49.0,
      description: "Bullet other tenant delivery"
    )

    get deliveries_path, headers: auth_header(@admin_token)

    assert_response :ok
    payload = JSON.parse(response.body)
    ids = payload.map { |delivery| delivery["id"] }

    assert_kind_of Array, payload
    assert_includes ids, tenant_delivery.id
    assert_not_includes ids, other_tenant_delivery.id
    assert_equal Delivery.where(business_id: @admin.business_id).count, payload.size
  end

  test "api keys index avoids bullet n+1 regressions" do
    tenant_key = ApiKey.create!(
      business: @admin.business,
      created_by_user: @admin,
      name: "Bullet tenant key",
      scopes: [ "deliveries:write" ]
    )
    other_tenant_key = ApiKey.create!(
      business: @other_tenant_user.business,
      created_by_user: @other_tenant_user,
      name: "Bullet other tenant key",
      scopes: [ "deliveries:write" ]
    )

    get api_keys_path, headers: auth_header(@admin_token)

    assert_response :ok
    payload = JSON.parse(response.body)
    ids = payload.map { |api_key| api_key["id"] }

    assert_kind_of Array, payload
    assert_includes ids, tenant_key.id
    assert_not_includes ids, other_tenant_key.id
    assert_equal ApiKey.where(business_id: @admin.business_id).count, payload.size
  end

  private

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
