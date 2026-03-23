class BusinessSettingsController < ApplicationController
  before_action :ensure_current_tenant
  before_action :ensure_can_read_business_settings, only: [ :show ]
  before_action :ensure_can_administer, only: [ :update ]

  def show
    render json: business_setting_response(current_business_setting)
  end

  def update
    business_setting = current_business_setting
    business_setting.update!(business_setting_params)

    render json: business_setting_response(business_setting)
  rescue ActiveRecord::RecordInvalid
    render json: { error: "business_setting_invalid" }, status: :unprocessable_entity
  end

  private

  def ensure_current_tenant
    head(:unauthorized) unless Current.tenant
  end

  def ensure_can_read_business_settings
    return if Current.actor&.admin? || Current.actor&.staff?

    head :forbidden
  end

  def current_business_setting
    @current_business_setting ||= Current.tenant.business_setting || Current.tenant.build_business_setting
  end

  def business_setting_params
    params.permit(
      :pickup_address1,
      :pickup_address2,
      :pickup_city,
      :pickup_region,
      :pickup_postal_code,
      :pickup_country_code,
      :pickup_latitude,
      :pickup_longitude,
      :pickup_contact_name,
      :pickup_contact_phone,
      :pickup_instructions
    )
  end

  def business_setting_response(business_setting)
    {
      id: business_setting.id,
      business_id: Current.tenant.id,
      pickup_address1: business_setting.pickup_address1,
      pickup_address2: business_setting.pickup_address2,
      pickup_city: business_setting.pickup_city,
      pickup_region: business_setting.pickup_region,
      pickup_postal_code: business_setting.pickup_postal_code,
      pickup_country_code: business_setting.pickup_country_code,
      pickup_latitude: business_setting.pickup_latitude,
      pickup_longitude: business_setting.pickup_longitude,
      pickup_contact_name: business_setting.pickup_contact_name,
      pickup_contact_phone: business_setting.pickup_contact_phone,
      pickup_instructions: business_setting.pickup_instructions,
      created_at: business_setting.created_at,
      updated_at: business_setting.updated_at
    }
  end
end
