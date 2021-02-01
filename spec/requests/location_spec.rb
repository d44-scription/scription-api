# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/locations', type: :request do
  let!(:notebook_1) { FactoryBot.create(:notebook) }
  let!(:notebook_2) { FactoryBot.create(:notebook) }

  let!(:location_1) { FactoryBot.create(:notable, :location, notebook: notebook_1, name: 'Location 1') }
  let!(:location_2) { FactoryBot.create(:notable, :location, notebook: notebook_1, name: 'Location 2') }
  let!(:location_3) { FactoryBot.create(:notable, :location, notebook: notebook_2, name: 'Location 3') }
  let!(:item) { FactoryBot.create(:notable, :item, notebook: notebook_1, name: 'Item') }
  let!(:character) { FactoryBot.create(:notable, :character, notebook: notebook_1, name: 'Character') }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'scopes response to currently viewed notebook' do
      get api_v1_notebook_locations_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(location_1.name)

      expect(response.body).not_to include(location_3.name)
      expect(response.body).not_to include(item.name)
      expect(response.body).not_to include(character.name)
    end

    it 'correctly sorts locations by order index' do
      location_1.update(order_index: 50)

      get api_v1_notebook_locations_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(location_1.name)
      expect(response.body).to include(location_2.name)

      json = JSON.parse(response.body)

      expect(json.first['name']).to eql(location_2.name)
      expect(json.second['name']).to eql(location_1.name)
    end

    describe 'when searching' do
      let!(:location_4) { FactoryBot.create(:notable, :location, notebook: notebook_1, name: 'Different Location') }
      let!(:location_5) { FactoryBot.create(:notable, :location, notebook: notebook_1, name: 'Another Location') }

      it 'returns a subset of locations matching the search query' do
        get api_v1_notebook_locations_url(notebook_1, q: 'Different'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).not_to include(location_1.name)
        expect(response.body).to include(location_4.name)
        expect(response.body).not_to include(location_5.name)

        expect(response.body).not_to include(location_3.name)
        expect(response.body).not_to include(item.name)
        expect(response.body).not_to include(character.name)
      end

      it 'returns an empty array when no locations match the query' do
        get api_v1_notebook_locations_url(notebook_1, q: 'TEST'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).not_to include(location_1.name)
        expect(response.body).not_to include(location_4.name)
        expect(response.body).not_to include(location_5.name)

        expect(response.body).not_to include(location_3.name)
        expect(response.body).not_to include(item.name)
        expect(response.body).not_to include(character.name)
      end

      it 'returns all locations when all match the query' do
        get api_v1_notebook_locations_url(notebook_1, q: 'Location'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).to include(location_1.name)
        expect(response.body).to include(location_4.name)
        expect(response.body).to include(location_5.name)

        expect(response.body).not_to include(location_3.name)
        expect(response.body).not_to include(item.name)
        expect(response.body).not_to include(character.name)
      end

      it 'ignores case when searching' do
        get api_v1_notebook_locations_url(notebook_1, q: 'aNoThEr'), headers: valid_headers, as: :json

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
