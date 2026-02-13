class BusinessLocationsController < ApplicationController
  before_action :ensure_current_tenant
  before_action :ensure_can_administer, only: [ :create, :update, :destroy ]
  before_action :set_business_location, only: [ :show, :update, :destroy ]

  def index
    locations = Current.tenant.business_locations.order(created_at: :desc)

    render json: locations.map { |location| location_response(location) }
  end

  def show
    render json: location_response(@business_location)
  end

  def create
    location = Current.tenant.business_locations.create!(business_location_params)

    render json: location_response(location), status: :created
  rescue ActiveRecord::RecordInvalid
    render json: { error: "business_location_invalid" }, status: :unprocessable_entity
  end

  def update
    @business_location.update!(business_location_params)

    render json: location_response(@business_location)
  rescue ActiveRecord::RecordInvalid
    render json: { error: "business_location_invalid" }, status: :unprocessable_entity
  end

  def destroy
    @business_location.destroy!

    head :no_content
  end

  private

  def ensure_current_tenant
    head :unauthorized unless Current.tenant
  end

  def set_business_location
    @business_location = Current.tenant.business_locations.find(params[:id])
  end

  def business_location_params
    params.permit(
      :name,
      :address1,
      :address2,
      :city,
      :region,
      :postal_code,
      :country_code,
      :latitude,
      :longitude,
      :instructions,
      :active
    )
  end

  def location_response(location)
    {
      id: location.id,
      business_id: location.business_id,
      name: location.name,
      address1: location.address1,
      address2: location.address2,
      city: location.city,
      region: location.region,
      postal_code: location.postal_code,
      country_code: location.country_code,
      latitude: location.latitude,
      longitude: location.longitude,
      instructions: location.instructions,
      active: location.active,
      created_at: location.created_at,
      updated_at: location.updated_at
    }
  end
end
