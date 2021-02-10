# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/users', type: :request do
  let!(:existing_user) { FactoryBot.create(:user) }

  let!(:valid_attributes) { FactoryBot.attributes_for(:user, display_name: 'Test Display Name') }
  let!(:invalid_attributes) { FactoryBot.attributes_for(:user, email: 'Invalid') }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    { 'Authorization': "Token #{existing_user.generate_jwt}" }
  end

  describe 'POST /registrations/create' do
    context 'with valid parameters' do
      it 'is permitted when not signed in' do
        expect do
          post user_registration_path, as: :json, params: { user: valid_attributes }
        end.to change(User, :count).by(1)
      end

      it 'renders a JSON response with the new user' do
        post user_registration_path, as: :json, params: { user: valid_attributes }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))

        expect(response.body).not_to include(existing_user.email)
        expect(response.body).to include(valid_attributes[:email])
        expect(response.body).to include(valid_attributes[:display_name])
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user' do
        expect do
          post user_registration_path,
               params: invalid_attributes, as: :json
        end.to change(User, :count).by(0)
      end

      it 'renders a JSON response with errors for the new user' do
        post user_registration_path,
             params: { user: invalid_attributes }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        expect(response.body).to include('email')
        expect(response.body).not_to include('password')
        expect(response.body).to include('is invalid')
      end
    end
  end
end
