class ApplicationController < ActionController::API
  include Authorization

  before_action :set_current_request_id
  before_action :authenticate_request

  private

  def set_current_request_id
    Current.request_id = request.request_id
  end

  def authenticate_request
    return if request.path == "/up"

    auth_header = request.authorization
    token = auth_header.to_s.delete_prefix("Bearer ")
    return head(:unauthorized) if token.empty?

    payload = Infra::Jwt.decode(token)
    return head(:unauthorized) if payload.nil?

    case payload["typ"]
    when "driver"
      driver = Driver.find_by(id: payload["sub"])
      return head(:unauthorized) unless driver

      Current.driver = driver
      Current.session = payload
    else
      user = User.find_by(id: payload["sub"], business_id: payload["biz"])
      return head(:unauthorized) unless user

      Current.actor = user
      Current.tenant = user.business
      Current.session = payload
    end
  rescue JWT::DecodeError, ArgumentError
    head :unauthorized
  end
end
