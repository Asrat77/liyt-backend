module Drivers
  class SessionsController < ApplicationController
    include TokenIssuer

    skip_before_action :authenticate_request, only: [ :create, :refresh, :revoke ]

    def create
      driver = Driver.find_by!(email: params[:email])
      return head(:unauthorized) unless driver.authenticate(params[:password])

      render json: issue_tokens(driver, driver_payload(driver)), status: :created
    rescue ActiveRecord::RecordNotFound
      head :unauthorized
    end

    def refresh
      token = params[:refresh_token].to_s
      return head(:unauthorized) if token.empty?

      token_hash = Infra::TokenHashing.digest(token)
      refresh_token = RefreshToken.find_by(token_hash: token_hash)
      return head(:unauthorized) unless refresh_token
      return head(:unauthorized) unless refresh_token.owner_type == "Driver"

      if refresh_token.revoked? || refresh_token.expired?
        refresh_token.revoke_family!
        return head(:unauthorized)
      end

      refresh_token.update!(last_used_at: Time.current, revoked_at: Time.current)
      render json: issue_tokens(
        refresh_token.owner,
        driver_payload(refresh_token.owner),
        family: refresh_token.family
      )
    end

    def revoke
      token = params[:refresh_token].to_s
      return head(:unauthorized) if token.empty?

      token_hash = Infra::TokenHashing.digest(token)
      refresh_token = RefreshToken.find_by(token_hash: token_hash)
      return head(:not_found) unless refresh_token
      return head(:not_found) unless refresh_token.owner_type == "Driver"

      refresh_token.revoke_family!
      head :no_content
    end
  end
end
