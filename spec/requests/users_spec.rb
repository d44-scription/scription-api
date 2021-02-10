# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/users', type: :request do
  let!(:user_1) { FactoryBot.create(:user, display_name: 'User 1') }
  let!(:user_2) { FactoryBot.create(:user, display_name: 'User 2') }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    { 'Authorization': "Token #{user_1.generate_jwt}" }
  end

  describe 'GET /show' do
    it 'is prohibited when not signed in' do
      get api_v1_user_path(user_1.id), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include("Not Authenticated")
    end

    it 'renders a successful response when note is linked to given notebook' do
      get api_v1_user_path(user_1.id), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(user_1.display_name)
      expect(response.body).to include(user_1.email)
      expect(response.body).to include(user_1.generate_jwt)

      expect(response.body).not_to include(user_2.display_name)
      expect(response.body).not_to include(user_2.email)
      expect(response.body).not_to include(user_2.generate_jwt)
    end
  end
end
