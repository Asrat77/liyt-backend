puts "Seeding Phase 1 baseline records..."

business = Business.find_or_create_by!(slug: "acme") do |record|
  record.name = "Acme Logistics"
  record.status = "active"
  record.support_email = "support@acme.test"
end

BusinessSetting.find_or_create_by!(business: business) do |record|
  record.pickup_address1 = "Bole Road"
  record.pickup_address2 = "Woreda 03"
  record.pickup_city = "Addis Ababa"
  record.pickup_region = "Addis Ababa"
  record.pickup_postal_code = "1000"
  record.pickup_country_code = "ET"
  record.pickup_latitude = 8.980603
  record.pickup_longitude = 38.757759
  record.pickup_contact_name = "Acme Dispatch"
  record.pickup_contact_phone = "+251911234567"
  record.pickup_instructions = "Ask at reception for dispatch desk"
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

puts "✓ #{Business.count} businesses, #{BusinessSetting.count} business settings, #{User.count} users, #{ApiKey.count} api keys seeded"
