# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/items', type: :request do
  let!(:notebook_1) { FactoryBot.create(:notebook) }
  let!(:notebook_2) { FactoryBot.create(:notebook) }

  let!(:item_1) { FactoryBot.create(:item, notebook: notebook_1, name: 'Item 1') }
  let!(:item_2) { FactoryBot.create(:item, notebook: notebook_1, name: 'Item 2') }
  let!(:item_3) { FactoryBot.create(:item, notebook: notebook_2, name: 'Item 3') }
  let!(:character) { FactoryBot.create(:character, notebook: notebook_1, name: 'Character') }
  let!(:location) { FactoryBot.create(:location, notebook: notebook_1, name: 'Location') }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'scopes response to currently viewed notebook' do
      get api_v1_notebook_items_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(item_1.name)
      expect(response.body).to include(item_1.text_code)

      expect(response.body).to include(item_2.name)
      expect(response.body).to include(item_2.text_code)

      expect(response.body).not_to include(item_3.name)
      expect(response.body).not_to include(character.name)
      expect(response.body).not_to include(location.name)
    end

    it 'correctly sorts items by order index' do
      item_1.update(order_index: 50)

      get api_v1_notebook_items_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(item_1.name)
      expect(response.body).to include(item_2.name)

      json = JSON.parse(response.body)

      expect(json.first['name']).to eql(item_2.name)
      expect(json.second['name']).to eql(item_1.name)
    end

    describe 'when searching' do
      let!(:item_4) { FactoryBot.create(:item, notebook: notebook_1, name: 'Different Item') }
      let!(:item_5) { FactoryBot.create(:item, notebook: notebook_1, name: 'Another Item') }

      it 'returns a subset of items matching the search query' do
        get api_v1_notebook_items_url(notebook_1, q: 'Different'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).not_to include(item_1.name)
        expect(response.body).to include(item_4.name)
        expect(response.body).not_to include(item_5.name)

        expect(response.body).not_to include(item_3.name)
        expect(response.body).not_to include(character.name)
        expect(response.body).not_to include(location.name)
      end

      it 'returns an empty array when no items match the query' do
        get api_v1_notebook_items_url(notebook_1, q: 'TEST'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).not_to include(item_1.name)
        expect(response.body).not_to include(item_4.name)
        expect(response.body).not_to include(item_5.name)

        expect(response.body).not_to include(item_3.name)
        expect(response.body).not_to include(character.name)
        expect(response.body).not_to include(location.name)
      end

      it 'returns all items when all match the query' do
        get api_v1_notebook_items_url(notebook_1, q: 'Item'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).to include(item_1.name)
        expect(response.body).to include(item_4.name)
        expect(response.body).to include(item_5.name)

        expect(response.body).not_to include(item_3.name)
        expect(response.body).not_to include(character.name)
        expect(response.body).not_to include(location.name)
      end

      it 'ignores case when searching' do
        get api_v1_notebook_items_url(notebook_1, q: 'aNoThEr'), headers: valid_headers, as: :json

        expect(response).to be_successful
        expect(response.body).not_to include(item_1.name)
        expect(response.body).not_to include(item_4.name)
        expect(response.body).to include(item_5.name)

        expect(response.body).not_to include(item_3.name)
        expect(response.body).not_to include(character.name)
        expect(response.body).not_to include(location.name)
      end
    end
  end
end
