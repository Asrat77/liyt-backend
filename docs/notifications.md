# Notifications

Goal

- Send SMS/email/push notifications reliably without blocking request threads.

Outbox

- `notification_messages` is the durable outbox.
- A worker sends messages and updates status/attempts.

Recipients

- Support notifications to `Recipient`, `Driver`, and business contacts.
