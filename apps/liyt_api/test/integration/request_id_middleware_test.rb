require "test_helper"

class RequestIdMiddlewareTest < ActionDispatch::IntegrationTest
  test "correlates response request id with provided header" do
    request_id = "req-correlation-123"

    get "/up", headers: { "X-Request-Id" => request_id }

    assert_response :success
    assert_equal request_id, response.headers["X-Request-Id"]
  end

  test "generates a fresh request id when header is not provided" do
    get "/up", headers: { "X-Request-Id" => "req-seeded-1" }
    assert_response :success
    assert_equal "req-seeded-1", response.headers["X-Request-Id"]

    get "/up"
    assert_response :success
    assert response.headers["X-Request-Id"].present?
    refute_equal "req-seeded-1", response.headers["X-Request-Id"]
  end

  test "cleans current request context after middleware call" do
    Current.request_id = "stale-value"

    app = lambda do |_env|
      assert_equal "req-cleanup-1", Current.request_id
      [ 200, { "Content-Type" => "application/json" }, [ "{}" ] ]
    end

    middleware = RequestIdMiddleware.new(app)
    env = Rack::MockRequest.env_for("/up", "action_dispatch.request_id" => "req-cleanup-1")

    status, = middleware.call(env)

    assert_equal 200, status
    assert_nil Current.request_id
  end
end
