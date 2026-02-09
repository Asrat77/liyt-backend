require 'openssl'

module Infra
  module TokenHashing
    def self.digest(raw)
      OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, raw)
    end
  end
end
