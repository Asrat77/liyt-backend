# Actors

Business staff (`User`)

- Uses business dashboard and business API.
- Creates deliveries, configures pricing, webhooks, and integrations.

Recipient (`Recipient`)

- Platform end-user (not tenanted).
- Receives deliveries from multiple businesses.
- Can create P2P deliveries from the recipient portal.
- Can Track a delivery with a tracking code.

Driver (`Driver`)

- Platform worker.
- Sets availability.
- Sees global feed of available deliveries.
- Accepts one delivery at a time (MVP rule enforced at app level).

System

- Maps provider (GebetaMaps).
- Notification providers (SMS/Email/Push) via `notification_messages` outbox.
- Webhook deliveries to business systems.
