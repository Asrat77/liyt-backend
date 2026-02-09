module Infra
  class Result
    attr_reader :value, :error

    def self.ok(value = nil)
      new(value:, error: nil)
    end

    def self.error(error)
      new(value: nil, error:)
    end

    def initialize(value:, error:)
      @value = value
      @error = error
    end

    def ok?
      error.nil?
    end

    def error?
      !ok?
    end
  end
end
