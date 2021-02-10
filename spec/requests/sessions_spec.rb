# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'devise/sessions', type: :request do
  let!(:user) { FactoryBot.create(:user, display_name: 'Test Display Name') }

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'renders a JSON response with the new session' do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))

        expect(response.body).to include(user.email)
        expect(response.body).to include(user.display_name)
        expect(response.body).not_to include('superSecret123!')
      end
    end

    context 'with invalid parameters' do
      it 'does not create when password does not match' do
        post user_session_url,
              params: { user: { email: user.email, password: '-' } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
        expect(response.body).to include('Email or password is invalid')
      end

      it 'does not create when email is not found' do
        post user_session_url,
              params: { user: { email: 'fake@example.com', password: 'superSecret123!' } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
        expect(response.body).to include('Email or password is invalid')
      end
    end
  end
end
