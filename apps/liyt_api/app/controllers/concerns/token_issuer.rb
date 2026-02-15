module TokenIssuer
  private

  def issue_tokens(owner, payload, family: nil)
    access_token = Infra::Jwt.encode(payload)

    refresh_raw = Infra::TokenGenerator.generate
    RefreshToken.create!(
      owner: owner,
      token_hash: Infra::TokenHashing.digest(refresh_raw),
      expires_at: 30.days.from_now,
      family: family || SecureRandom.uuid
    )

    {
      access_token: access_token,
      refresh_token: refresh_raw,
      token_type: "Bearer",
      expires_in: 120.minutes.to_i
    }
  end

  def user_payload(user)
    {
      "sub" => user.id,
      "biz" => user.business_id,
      "role" => user.roles.pluck(:name),
      "typ" => "user"
    }
  end

  def driver_payload(driver)
    {
      "sub" => driver.id,
      "typ" => "driver"
    }
  end
end
