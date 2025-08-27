module Api
  class AuthenticationController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:login]
    skip_after_action :verify_authorized, only: [:login]
    skip_after_action :verify_policy_scoped, only: [:login]  # <--- Add this

    def login
      user = User.find_by(email: params[:email])
      if user&.valid_password?(params[:password])
        token = encode_token(user_id: user.id)
        render json: { token: token }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    private

    def encode_token(payload)
      JWT.encode(payload, Rails.application.secret_key_base)
    end
  end
end
