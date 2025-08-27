class Api::BaseController < ApplicationController
  include Pundit::Authorization

  # Skip CSRF for API
  skip_before_action :verify_authenticity_token

  before_action :authenticate_api_user!
  # Enforce authorization for single records
  after_action :verify_authorized, except: :index
  # Enforce scoping only for index
  after_action :verify_policy_scoped, only: :index
  efore_action :authenticate_request
  private

  def authenticate_api_user!
    header = request.headers['Authorization']
    token = header.split(' ').last if header.present?

    if token
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      @current_api_user = User.find_by(id: decoded['user_id'])
    end

    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_api_user
  rescue JWT::DecodeError
    render json: { error: 'Invalid token' }, status: :unauthorized
  end

  def current_api_user
    @current_api_user
  end

  # 👇 This is the important bit (Pundit expects `current_user`)
  def pundit_user
    current_api_user
  end
end
