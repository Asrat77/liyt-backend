module Infra
  module TokenGenerator
    def self.generate
      SecureRandom.hex(32)
    end
  end
end
