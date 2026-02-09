class Current < ActiveSupport::CurrentAttributes
  attribute :request_id, :actor, :tenant, :driver, :recipient, :session
end
