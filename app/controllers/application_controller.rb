# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  respond_to :json

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:display_name])
  end

  def authenticate_user
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized && return unless request.headers['Authorization'].present?

    authenticate_or_request_with_http_token do |token|
      jwt_payload = JWT.decode(token, Rails.application.secrets.secret_key_base).first

      @current_user_id = jwt_payload['id']
    rescue JWT::VerificationError
      render json: { errors: ['Verification error'] }, status: :unauthorized
    end

    rescue JWT::ExpiredSignature
      render json: { errors: ['Expired signature'] }, status: :unauthorized
    end

  rescue  JWT::DecodeError
      render json: { errors: ['Decode error'] }, status: :unauthorized
    end
  end

  def authenticate_user!(_options = {})
    render json: { errors: ['Not signed in'] }, status: :unauthorized unless signed_in?
  end

  def current_user
    @current_user ||= super || User.find(@current_user_id)
  end

  def signed_in?
    @current_user_id.present?
  end
end
