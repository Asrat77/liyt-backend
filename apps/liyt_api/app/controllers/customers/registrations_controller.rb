module Customers
  class RegistrationsController < ApplicationController
    include TokenIssuer

    skip_before_action :authenticate_request, only: [ :create ]

    def create
      business = registration_business

      user = nil
      ApplicationRecord.transaction do
        user = User.create!(
          business: business,
          email: registration_params[:email],
          password: registration_params[:password]
        )

        customer_role = Role.find_or_create_by!(business: business, name: "customer")
        UserRole.create!(user: user, role: customer_role)
      end

      render json: issue_tokens(user, user_payload(user)).merge(
        user: user_response(user),
        roles: user.roles.pluck(:name)
      ), status: :created
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
      render json: { error: "registration_invalid" }, status: :unprocessable_entity
    end

    private

    def registration_params
      params.permit(:email, :password, :full_name, :phone)
    end

    def registration_business
      Business.find_by(status: "active") || Business.order(:id).first!
    end

    def user_response(user)
      {
        id: user.id,
        email: user.email,
        business_id: user.business_id
      }
    end
  end
end
