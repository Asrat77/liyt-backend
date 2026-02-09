```ruby
# Example atomic accept (conceptual)

Delivery.transaction do
  delivery = Delivery.lock.find(delivery_id)

  # Guard: only accept if still available
  unless delivery.status == "pending" && delivery.driver_id.nil?
    raise ActiveRecord::RecordInvalid, "Delivery not available"
  end

  delivery.update!(
    driver_id: Current.driver.id,
    status: "accepted",
    accepted_at: Time.current
  )

  delivery.delivery_events.create!(
    event_type: "status_changed",
    from_status: "pending",
    to_status: "accepted",
    actor_type: "Driver",
    actor_id: Current.driver.id,
    occurred_at: Time.current
  )
end
```
