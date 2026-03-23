class ApiKeysController < ApplicationController
  DEFAULT_SCOPES = [ "deliveries:write" ].freeze

  before_action :ensure_current_tenant
  before_action :ensure_can_read_api_keys, only: [ :index, :show ]
  before_action :ensure_can_administer, only: [ :create, :revoke, :rotate ]
  before_action :set_api_key, only: [ :show, :revoke, :rotate ]

  def index
    api_keys = Current.tenant.api_keys.order(created_at: :desc)

    render json: api_keys.map { |api_key| api_key_response(api_key) }
  end

  def show
    render json: api_key_response(@api_key)
  end

  def create
    api_key = Current.tenant.api_keys.create!(
      **api_key_params,
      scopes: create_scopes,
      created_by_user: Current.actor
    )

    render json: api_key_response(api_key, plaintext_key: api_key.plaintext_key), status: :created
  rescue ActiveRecord::RecordInvalid
    render json: { error: "api_key_invalid" }, status: :unprocessable_entity
  end

  def revoke
    revoke_key(@api_key)

    render json: api_key_response(@api_key)
  end

  def rotate
    replacement = nil

    ApiKey.transaction do
      revoke_key(@api_key)
      replacement = Current.tenant.api_keys.create!(
        name: rotate_name,
        scopes: rotate_scopes,
        expires_at: rotate_expires_at,
        created_by_user: Current.actor
      )
    end

    render json: api_key_response(replacement, plaintext_key: replacement.plaintext_key), status: :created
  rescue ActiveRecord::RecordInvalid
    render json: { error: "api_key_invalid" }, status: :unprocessable_entity
  end

  private

  def ensure_current_tenant
    head(:unauthorized) unless Current.tenant
  end

  def ensure_can_read_api_keys
    return if Current.actor&.admin? || Current.actor&.staff?

    head :forbidden
  end

  def set_api_key
    @api_key = Current.tenant.api_keys.find(params[:id])
  end

  def api_key_params
    params.permit(:name, :expires_at, scopes: [])
  end

  def create_scopes
    api_key_params[:scopes].presence || DEFAULT_SCOPES
  end

  def rotate_scopes
    api_key_params[:scopes].presence || @api_key.scopes.presence || DEFAULT_SCOPES
  end

  def rotate_name
    api_key_params[:name].presence || @api_key.name
  end

  def rotate_expires_at
    api_key_params.key?(:expires_at) ? api_key_params[:expires_at] : @api_key.expires_at
  end

  def revoke_key(api_key)
    return if api_key.revoked?

    api_key.update!(revoked_at: Time.current, revoked_by_user: Current.actor)
  end

  def api_key_response(api_key, plaintext_key: nil)
    {
      id: api_key.id,
      business_id: api_key.business_id,
      name: api_key.name,
      prefix: api_key.prefix,
      scopes: api_key.scopes,
      last_used_at: api_key.last_used_at,
      expires_at: api_key.expires_at,
      revoked_at: api_key.revoked_at,
      created_by_user_id: api_key.created_by_user_id,
      revoked_by_user_id: api_key.revoked_by_user_id,
      created_at: api_key.created_at,
      updated_at: api_key.updated_at,
      plaintext_key: plaintext_key
    }
  end
end
