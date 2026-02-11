class AuthRateLimit
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) unless request.post?

    case request.path
    when "/auth/sessions", "/auth/sessions/refresh", "/auth/sessions/revoke",
         "/auth/registrations", "/drivers/sessions", "/drivers/sessions/refresh",
         "/drivers/sessions/revoke", "/drivers/registrations"
      token = RequestThrottle.new(request).call
      return token if token
    end

    @app.call(env)
  end

  private

  class RequestThrottle
    MAX_ATTEMPTS = 30
    WINDOW = 60

    def initialize(request)
      @request = request
    end

    def call
      key = "auth:rate:#{ip}"
      count = Rails.cache.increment(key, 1, expires_in: WINDOW) || 1
      return if count <= MAX_ATTEMPTS

      [
        429,
        { "Content-Type" => "application/json" },
        [ { error: "rate_limited" }.to_json ]
      ]
    end

    private

    attr_reader :request

    def ip
      request.ip.to_s
    end
  end
end
