require "test_helper"

class AuthRateLimitTest < ActiveSupport::TestCase
  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.clear
  end

  teardown do
    Rails.cache = @original_cache
  end

  test "throttles protected auth posts after max attempts" do
    app = AuthRateLimit.new(->(_env) { [ 200, { "Content-Type" => "application/json" }, [ "{}" ] ] })

    30.times do
      status, = app.call(post_env_for("/auth/sessions", "203.0.113.10"))
      assert_equal 200, status
    end

    status, headers, body = app.call(post_env_for("/auth/sessions", "203.0.113.10"))

    assert_equal 429, status
    assert_equal "application/json", headers["Content-Type"]
    assert_includes body.join, "rate_limited"
  end

  test "does not throttle non protected methods and paths" do
    app = AuthRateLimit.new(->(_env) { [ 200, { "Content-Type" => "application/json" }, [ "{}" ] ] })

    35.times do
      get_status, = app.call(get_env_for("/auth/sessions", "198.51.100.11"))
      post_status, = app.call(post_env_for("/customers/confirmation/confirm", "198.51.100.11"))

      assert_equal 200, get_status
      assert_equal 200, post_status
    end
  end

  test "scopes throttling key by client ip across protected auth paths" do
    app = AuthRateLimit.new(->(_env) { [ 200, { "Content-Type" => "application/json" }, [ "{}" ] ] })

    30.times do
      status, = app.call(post_env_for("/auth/sessions", "203.0.113.22"))
      assert_equal 200, status
    end

    throttled_status, = app.call(post_env_for("/drivers/sessions", "203.0.113.22"))
    other_ip_status, = app.call(post_env_for("/auth/sessions", "203.0.113.23"))

    assert_equal 429, throttled_status
    assert_equal 200, other_ip_status
  end

  private

  def post_env_for(path, ip)
    Rack::MockRequest.env_for(path, method: "POST", "REMOTE_ADDR" => ip)
  end

  def get_env_for(path, ip)
    Rack::MockRequest.env_for(path, method: "GET", "REMOTE_ADDR" => ip)
  end
end
