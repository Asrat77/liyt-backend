require 'jwt'

module Infra
  module Jwt
    ALGORITHM = 'HS256'.freeze
    DEFAULT_TTL = 15.minutes

    def self.encode(payload, ttl: DEFAULT_TTL)
      exp = ttl.from_now.to_i
      JWT.encode(payload.merge('exp' => exp), secret, ALGORITHM)
    end

    def self.decode(token)
      decoded = JWT.decode(token, secret, true, algorithm: ALGORITHM)
      decoded.first
    rescue JWT::ExpiredSignature, JWT::DecodeError
      nil
    end

    def self.secret
      Rails.application.secret_key_base
    end
  end
end
