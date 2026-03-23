class Current < ActiveSupport::CurrentAttributes
  attribute :request_id, :actor, :tenant, :driver, :recipient, :session, :api_key
end
