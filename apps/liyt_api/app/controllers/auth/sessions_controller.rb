module Auth
  class SessionsController < ApplicationController
    skip_before_action :authenticate_request, only: [ :create, :refresh, :revoke ]

    def create
      user = User.find_by!(business_id: params[:business_id], email: params[:email])
      return head(:unauthorized) unless user.authenticate(params[:password])

      render json: build_tokens(user), status: :created
    rescue ActiveRecord::RecordNotFound
      head :unauthorized
    end

    def refresh
      token = params[:refresh_token].to_s
      return head(:unauthorized) if token.empty?

      token_hash = Infra::TokenHashing.digest(token)
      refresh_token = RefreshToken.active.find_by(token_hash: token_hash)
      return head(:unauthorized) unless refresh_token

      refresh_token.update!(last_used_at: Time.current)
      render json: build_tokens(refresh_token.owner)
    end

    def revoke
      token = params[:refresh_token].to_s
      return head(:unauthorized) if token.empty?

      token_hash = Infra::TokenHashing.digest(token)
      refresh_token = RefreshToken.find_by(token_hash: token_hash)
      return head(:not_found) unless refresh_token

      refresh_token.revoke!
      head :no_content
    end

    private

    def build_tokens(user)
      access_token = Infra::Jwt.encode({
        "sub" => user.id,
        "biz" => user.business_id,
        "role" => user.roles.pluck(:name)
      })

      refresh_raw = Infra::TokenGenerator.generate
      RefreshToken.create!(
        owner: user,
        token_hash: Infra::TokenHashing.digest(refresh_raw),
        expires_at: 30.days.from_now
      )

      {
        access_token: access_token,
        refresh_token: refresh_raw,
        token_type: "Bearer",
        expires_in: 15.minutes.to_i
      }
    end
  end
end
