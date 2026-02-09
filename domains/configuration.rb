module Liyt
  class Configuration
    def initialize(registrations: [])
      @registrations = registrations
    end

    def call
      registrations.each(&:call)
    end

    private

    attr_reader :registrations
  end
end
