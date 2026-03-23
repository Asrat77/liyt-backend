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

    if api_key_auth_allowed? && api_key_header.present?
      return authenticate_api_key_request
    end

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

  def api_key_header
    request.headers["X-API-Key"].presence
  end

  def api_key_auth_allowed?
    controller_name == "deliveries" && action_name == "create" && request.post?
  end

  def authenticate_api_key_request
    api_key = find_active_api_key(api_key_header)
    return head(:unauthorized) unless api_key

    Current.api_key = api_key
    Current.tenant = api_key.business
    api_key.update_column(:last_used_at, Time.current)
  end

  def find_active_api_key(raw_key)
    return if raw_key.blank?

    ApiKey.active.find_by(prefix: raw_key.first(12), key_hash: Infra::TokenHashing.digest(raw_key))
  end
end
