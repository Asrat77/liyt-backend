puts "Seeding Phase 1 baseline records..."

business = Business.find_or_create_by!(slug: "acme") do |record|
  record.name = "Acme Logistics"
  record.status = "active"
  record.support_email = "support@acme.test"
end

admin_user = User.find_or_create_by!(email: "admin@acme.test") do |record|
  record.business = business
  record.password = "password"
  record.password_confirmation = "password"
end

ApiKey.find_or_create_by!(prefix: "acmephase1k1") do |record|
  record.business = business
  record.created_by_user = admin_user
  record.name = "Acme Delivery Integration"
  record.key_hash = Infra::TokenHashing.digest("acmephase1k1.seed-secret")
  record.scopes = [ "deliveries:write" ]
  record.expires_at = 1.year.from_now
end

puts "✓ #{Business.count} businesses, #{User.count} users, #{ApiKey.count} api keys seeded"
