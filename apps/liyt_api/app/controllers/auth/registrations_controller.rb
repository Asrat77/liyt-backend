module Auth
  class RegistrationsController < ApplicationController
    include TokenIssuer

    skip_before_action :authenticate_request, only: [ :create ]

    def create
      business = nil
      user = nil

      ApplicationRecord.transaction do
        business = Business.create!(name: params[:business_name])

        user = User.create!(
          business: business,
          email: params[:email],
          password: params[:password]
        )

        admin_role = Role.find_or_create_by!(business: business, name: "admin")
        UserRole.create!(user: user, role: admin_role)
      end

      render json: issue_tokens(user, user_payload(user)).merge(
        user: user_response(user),
        business: business_response(business),
        roles: user.roles.pluck(:name)
      ), status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { error: "registration_invalid" }, status: :unprocessable_entity
    end

    private

    def user_response(user)
      {
        id: user.id,
        email: user.email,
        business_id: user.business_id
      }
    end

    def business_response(business)
      {
        id: business.id,
        name: business.name,
        slug: business.slug
      }
    end
  end
end
