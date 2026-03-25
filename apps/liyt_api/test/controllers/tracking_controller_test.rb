require "test_helper"

class TrackingControllerTest < ActionDispatch::IntegrationTest
  test "returns not found for unknown token" do
    get tracking_path("missing-token")

    assert_response :not_found
  end

  test "returns not found for token tied to unconfirmed delivery" do
    get tracking_path(delivery_tracking_tokens(:token_one).token_hash)

    assert_response :not_found
  end

  test "returns gone for expired token" do
    get tracking_path(delivery_tracking_tokens(:token_expired).token_hash)

    assert_response :gone
  end
end
