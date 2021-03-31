# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/locations', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  let!(:notebook_1) { FactoryBot.create(:notebook, user: user) }
  let!(:notebook_2) { FactoryBot.create(:notebook, user: user) }

  let!(:location_1) { FactoryBot.create(:location, notebook: notebook_1, name: 'Location 1') }
  let!(:location_2) { FactoryBot.create(:location, notebook: notebook_1, name: 'Location 2') }
  let!(:location_3) { FactoryBot.create(:location, notebook: notebook_2, name: 'Location 3') }
  let!(:item) { FactoryBot.create(:item, notebook: notebook_1, name: 'Item') }
  let!(:character) { FactoryBot.create(:character, notebook: notebook_1, name: 'Character') }

  describe 'GET /index' do
    it 'is prohibited when not signed in' do
      get api_v1_notebook_locations_url(notebook_1), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'scopes response to currently viewed notebook' do
        get api_v1_notebook_locations_url(notebook_1), as: :json

        expect(response).to be_successful
        expect(response.body).to include(location_1.name)
        expect(response.body).to include(location_1.text_code)
        expect(response.body).to include(location_2.name)
        expect(response.body).to include(location_2.text_code)

        expect(response.body).not_to include(location_3.name)
        expect(response.body).not_to include(item.name)
        expect(response.body).not_to include(character.name)
      end

      it 'correctly sorts locations alphabetically' do
        location_1.update(name: 'zz_location')

        get api_v1_notebook_locations_url(notebook_1), as: :json

        expect(response).to be_successful
        expect(response.body).to include(location_1.name)
        expect(response.body).to include(location_2.name)

        json = JSON.parse(response.body)

        expect(json.first['name']).to eql(location_2.name)
        expect(json.second['name']).to eql(location_1.name)
      end

      describe 'when searching' do
        let!(:location_4) { FactoryBot.create(:location, notebook: notebook_1, name: 'Different Location') }
        let!(:location_5) { FactoryBot.create(:location, notebook: notebook_1, name: 'Another Location') }

        it 'returns a subset of locations matching the search query' do
          get api_v1_notebook_locations_url(notebook_1, q: 'Different'), as: :json

          expect(response).to be_successful
          expect(response.body).not_to include(location_1.name)
          expect(response.body).to include(location_4.name)
          expect(response.body).not_to include(location_5.name)

          expect(response.body).not_to include(location_3.name)
          expect(response.body).not_to include(item.name)
          expect(response.body).not_to include(character.name)
        end

        it 'returns an empty array when no locations match the query' do
          get api_v1_notebook_locations_url(notebook_1, q: 'TEST'), as: :json

          expect(response).to be_successful
          expect(response.body).not_to include(location_1.name)
          expect(response.body).not_to include(location_4.name)
          expect(response.body).not_to include(location_5.name)

          expect(response.body).not_to include(location_3.name)
          expect(response.body).not_to include(item.name)
          expect(response.body).not_to include(character.name)
        end

        it 'returns all locations when all match the query' do
          get api_v1_notebook_locations_url(notebook_1, q: 'Location'), as: :json

          expect(response).to be_successful
          expect(response.body).to include(location_1.name)
          expect(response.body).to include(location_4.name)
          expect(response.body).to include(location_5.name)

          expect(response.body).not_to include(location_3.name)
          expect(response.body).not_to include(item.name)
          expect(response.body).not_to include(character.name)
        end

        it 'ignores case when searching' do
          get api_v1_notebook_locations_url(notebook_1, q: 'aNoThEr'), as: :json

          expect(response).to be_successful
          expect(response.body).not_to include(location_1.name)
          expect(response.body).not_to include(location_4.name)
          expect(response.body).to include(location_5.name)

          expect(response.body).not_to include(location_3.name)
          expect(response.body).not_to include(item.name)
          expect(response.body).not_to include(character.name)
        end
      end
    end
  end
end
