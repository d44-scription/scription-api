# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/characters', type: :request do
  let!(:notebook_1) { FactoryBot.create(:notebook) }
  let!(:notebook_2) { FactoryBot.create(:notebook) }

  let!(:character_1) { FactoryBot.create(:notable, :character, notebook: notebook_1, name: 'Character 1') }
  let!(:character_2) { FactoryBot.create(:notable, :character, notebook: notebook_1, name: 'Character 2') }
  let!(:character_3) { FactoryBot.create(:notable, :character, notebook: notebook_2, name: 'Character 3') }
  let!(:item) { FactoryBot.create(:notable, :item, notebook: notebook_1, name: 'Item') }
  let!(:location) { FactoryBot.create(:notable, :location, notebook: notebook_1, name: 'Location') }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'scopes response to currently viewed notebook' do
      get api_v1_notebook_characters_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(character_1.name)
      expect(response.body).to include(character_2.name)

      expect(response.body).not_to include(character_3.name)
      expect(response.body).not_to include(item.name)
      expect(response.body).not_to include(location.name)
    end

    it 'correctly sorts characters by order index' do
      character_1.update(order_index: 50)

      get api_v1_notebook_characters_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(character_1.name)
      expect(response.body).to include(character_2.name)

      json = JSON.parse(response.body)

      expect(json.first['name']).to eql(character_2.name)
      expect(json.second['name']).to eql(character_1.name)
    end

    describe 'when searching' do
      let!(:character_4) { FactoryBot.create(:notable, :character, notebook: notebook_1, name: 'Different Character') }
      let!(:character_5) { FactoryBot.create(:notable, :character, notebook: notebook_1, name: 'Another Character') }

      it 'returns a subset of characters matching the search query' do
        get api_v1_notebook_characters_url(notebook_1, q: 'Different'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).not_to include(character_1.name)
        expect(response.body).to include(character_4.name)
        expect(response.body).not_to include(character_5.name)

        expect(response.body).not_to include(character_3.name)
        expect(response.body).not_to include(item.name)
        expect(response.body).not_to include(location.name)
      end

      it 'returns an empty array when no characters match the query' do
        get api_v1_notebook_characters_url(notebook_1, q: 'TEST'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).not_to include(character_1.name)
        expect(response.body).not_to include(character_4.name)
        expect(response.body).not_to include(character_5.name)

        expect(response.body).not_to include(character_3.name)
        expect(response.body).not_to include(item.name)
        expect(response.body).not_to include(location.name)
      end

      it 'returns all characters when all match the query' do
        get api_v1_notebook_characters_url(notebook_1, q: 'Character'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).to include(character_1.name)
        expect(response.body).to include(character_4.name)
        expect(response.body).to include(character_5.name)

        expect(response.body).not_to include(character_3.name)
        expect(response.body).not_to include(item.name)
        expect(response.body).not_to include(location.name)
      end

      it 'ignores case when searching' do
        get api_v1_notebook_characters_url(notebook_1, q: 'aNoThEr'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).not_to include(character_1.name)
        expect(response.body).not_to include(character_4.name)
        expect(response.body).to include(character_5.name)

        expect(response.body).not_to include(character_3.name)
        expect(response.body).not_to include(item.name)
        expect(response.body).not_to include(location.name)
      end
    end
  end
end
