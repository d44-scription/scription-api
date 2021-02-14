# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/users', type: :request do
  let!(:user_1) { FactoryBot.create(:user, display_name: 'User 1') }
  let!(:user_2) { FactoryBot.create(:user, display_name: 'User 2') }

  describe 'GET /show' do
    it 'is prohibited when not signed in' do
      get api_v1_user_url(user_1.id), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

  context 'when signed in' do
    before do
      post user_session_url, as: :json, params: { user: { email: user_1.email, password: 'superSecret123!' } }
    end

      it 'renders a successful response when note is linked to given notebook' do
        get api_v1_user_url(user_1.id), as: :json

        expect(response).to be_successful
        expect(response.body).to include(user_1.display_name)
        expect(response.body).to include(user_1.email)

        expect(response.body).not_to include(user_2.display_name)
        expect(response.body).not_to include(user_2.email)
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { FactoryBot.attributes_for(:user, display_name: 'Updated User', email: 'updated@example.com') }

      it 'is prohibited when not signed in' do
        expect do
          patch api_v1_user_url(user_1.id),
                params: new_attributes, as: :json
        end.to change(User, :count).by(0)

        user_1.reload
        expect(user_1.display_name).not_to eql(new_attributes[:display_name])
        expect(user_1.email).not_to eql(new_attributes[:email])

        expect(response).to be_unauthorized
        expect(response.body).to include('Not Authenticated')
      end

      context 'when signed in' do
        before do
          post user_session_url, as: :json, params: { user: { email: user_1.email, password: 'superSecret123!' } }
        end

        it 'updates the requested user' do
          expect do
            patch api_v1_user_url(user_1),
                  params: new_attributes, as: :json
          end.to change(User, :count).by(0)

          user_1.reload
          expect(user_1.display_name).to eql(new_attributes[:display_name])
          expect(user_1.email).to eql(new_attributes[:email])
        end

        it 'renders a JSON response with the user' do
          patch api_v1_user_url(user_1),
                params: new_attributes, as: :json

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { FactoryBot.attributes_for(:user, email: '-') }

      before do
        post user_session_url, as: :json, params: { user: { email: user_1.email, password: 'superSecret123!' } }
      end

      it 'renders a JSON response with errors for the notebook' do
        patch api_v1_user_url(user_1),
              params: invalid_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        user_1.reload
        expect(user_1.email).not_to eql('-')
        expect(response.body).to include('Email is invalid')
      end
    end
  end
end
