# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authorise_request

  private

  def authorise_request
    AuthorisationService.new(request.headers).authenticate_request!
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end
end
