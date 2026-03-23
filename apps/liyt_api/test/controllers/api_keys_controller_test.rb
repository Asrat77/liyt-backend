require "test_helper"

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @staff = User.create!(
      business: @admin.business,
      email: "staff-one@acme.test",
      password: "password",
      password_confirmation: "password"
    )
    @staff.roles << Role.create!(business: @admin.business, name: "staff")

    @other_tenant_user = users(:two)

    @admin_token = Infra::Jwt.encode({ "sub" => @admin.id, "biz" => @admin.business_id, "typ" => "user" })
    @staff_token = Infra::Jwt.encode({ "sub" => @staff.id, "biz" => @staff.business_id, "typ" => "user" })

    @active_key = api_keys(:active)
    @other_tenant_key = ApiKey.create!(
      business: @other_tenant_user.business,
      created_by_user: @other_tenant_user,
      name: "Beta Integration",
      scopes: [ "deliveries:write" ]
    )
  end

  test "admin lists api keys for current tenant without plaintext" do
    get api_keys_path, headers: auth_header(@admin_token)

    assert_response :ok
    body = JSON.parse(response.body)
    ids = body.map { |key| key["id"] }

    assert_includes ids, api_keys(:active).id
    assert_includes ids, api_keys(:expired).id
    assert_includes ids, api_keys(:revoked).id
    assert_not_includes ids, @other_tenant_key.id
    assert_nil body.first["plaintext_key"]
    assert_nil body.first["key_hash"]
  end

  test "staff can list api keys" do
    get api_keys_path, headers: auth_header(@staff_token)

    assert_response :ok
    body = JSON.parse(response.body)
    ids = body.map { |key| key["id"] }

    assert_includes ids, api_keys(:active).id
    assert_not_includes ids, @other_tenant_key.id
  end

  test "admin creates api key and sees plaintext key once" do
    assert_difference -> { ApiKey.count }, 1 do
      post api_keys_path,
        params: { name: "Orders Integration", scopes: [ "deliveries:write" ] },
        headers: auth_header(@admin_token)
    end

    assert_response :created
    body = JSON.parse(response.body)

    assert body["plaintext_key"].present?
    assert_equal "Orders Integration", body["name"]
    assert_nil body["key_hash"]

    created_key = ApiKey.find(body["id"])
    assert_equal @admin.business_id, created_key.business_id
    assert_equal @admin.id, created_key.created_by_user_id
    assert_equal Infra::TokenHashing.digest(body["plaintext_key"]), created_key.key_hash

    get api_key_path(created_key), headers: auth_header(@admin_token)

    assert_response :ok
    shown = JSON.parse(response.body)
    assert_nil shown["plaintext_key"]
  end

  test "staff is forbidden from creating api keys" do
    post api_keys_path,
      params: { name: "Forbidden", scopes: [ "deliveries:write" ] },
      headers: auth_header(@staff_token)

    assert_response :forbidden
  end

  test "shows key metadata for current tenant without plaintext" do
    get api_key_path(@active_key), headers: auth_header(@admin_token)

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal @active_key.id, body["id"]
    assert_nil body["plaintext_key"]
    assert_nil body["key_hash"]
  end

  test "staff can show key metadata" do
    get api_key_path(@active_key), headers: auth_header(@staff_token)

    assert_response :ok
    body = JSON.parse(response.body)

    assert_equal @active_key.id, body["id"]
    assert_nil body["plaintext_key"]
  end

  test "returns not found for key outside current tenant" do
    get api_key_path(@other_tenant_key), headers: auth_header(@admin_token)

    assert_response :not_found
  end

  test "admin revokes key and tracks revoked_by_user" do
    assert_nil @active_key.revoked_at

    patch revoke_api_key_path(@active_key), headers: auth_header(@admin_token)

    assert_response :ok
    @active_key.reload

    assert @active_key.revoked_at.present?
    assert_equal @admin.id, @active_key.revoked_by_user_id
  end

  test "staff is forbidden from revoking" do
    patch revoke_api_key_path(@active_key), headers: auth_header(@staff_token)

    assert_response :forbidden
  end

  test "admin rotates key revoking old key and returning new plaintext" do
    old_id = @active_key.id
    old_scopes = @active_key.scopes

    assert_difference -> { ApiKey.count }, 1 do
      patch rotate_api_key_path(@active_key), headers: auth_header(@admin_token)
    end

    assert_response :created
    body = JSON.parse(response.body)

    assert body["plaintext_key"].present?

    @active_key.reload
    assert @active_key.revoked_at.present?
    assert_equal @admin.id, @active_key.revoked_by_user_id

    rotated = ApiKey.find(body["id"])
    refute_equal old_id, rotated.id
    assert_equal old_scopes, rotated.scopes
    assert_equal @admin.id, rotated.created_by_user_id
    assert_equal Infra::TokenHashing.digest(body["plaintext_key"]), rotated.key_hash
  end

  test "staff is forbidden from rotating" do
    patch rotate_api_key_path(@active_key), headers: auth_header(@staff_token)

    assert_response :forbidden
  end

  private

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
