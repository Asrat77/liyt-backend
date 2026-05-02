if ENV["COVERAGE"] == "1"
  require "simplecov"

  SimpleCov.command_name "Minitest"

  SimpleCov.start "rails" do
    enable_coverage :branch
    track_files "app/**/*.rb"
    add_filter "/test/"
  end
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    bullet_serialized_run = ENV["BULLET_SERIAL_TESTS"] == "1"
    coverage_serialized_run = ENV["COVERAGE"] == "1"
    serialized_run = bullet_serialized_run || coverage_serialized_run
    parallelize(workers: serialized_run ? 1 : :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
