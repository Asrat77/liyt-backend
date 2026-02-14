require_relative "../../../../infra/lib/infra"
require_relative "../../../../domains/configuration"
require_relative "../../../../domains/delivery/registration"

Liyt::Configuration.new(
  registrations: [
    Deliveries::Registration.new
  ]
).call
