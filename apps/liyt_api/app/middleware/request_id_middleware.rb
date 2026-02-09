class RequestIdMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request_id = env["action_dispatch.request_id"] || SecureRandom.uuid
    env["action_dispatch.request_id"] = request_id
    Current.request_id = request_id

    @app.call(env)
  ensure
    Current.reset
  end
end
