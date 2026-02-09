```ruby
# API key / tracking token hashing pattern (conceptual)

raw = SecureRandom.hex(32)
prefix = raw[0, 8]
hash = OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, raw)

# Store: prefix + hash
# Return to user: raw
```
