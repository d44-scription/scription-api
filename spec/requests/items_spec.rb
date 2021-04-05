# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/items', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  let!(:notebook_1) { FactoryBot.create(:notebook, user: user) }
  let!(:notebook_2) { FactoryBot.create(:notebook, user: user) }

  let!(:item_1) { FactoryBot.create(:item, notebook: notebook_1, name: 'Item 1') }
  let!(:item_2) { FactoryBot.create(:item, notebook: notebook_1, name: 'Item 2') }
  let!(:item_3) { FactoryBot.create(:item, notebook: notebook_2, name: 'Item 3') }
  let!(:character) { FactoryBot.create(:character, notebook: notebook_1, name: 'Character') }
  let!(:location) { FactoryBot.create(:location, notebook: notebook_1, name: 'Location') }

  describe 'GET /index' do
    it 'is prohibited when not signed in' do
      get api_v1_notebook_items_url(notebook_1), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'scopes response to currently viewed notebook' do
        get api_v1_notebook_items_url(notebook_1), as: :json

        expect(response).to be_successful
        expect(response.body).to include(item_1.name)
        expect(response.body).to include(item_1.text_code)

        expect(response.body).to include(item_2.name)
        expect(response.body).to include(item_2.text_code)

        expect(response.body).not_to include(item_3.name)
        expect(response.body).not_to include(character.name)
        expect(response.body).not_to include(location.name)
      end

      it 'correctly sorts items alphabetically' do
        item_1.update(name: 'zz_item')

        get api_v1_notebook_items_url(notebook_1), as: :json

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
          get api_v1_notebook_items_url(notebook_1, q: 'Different'), as: :json

          expect(response).to be_successful
          expect(response.body).not_to include(item_1.name)
          expect(response.body).to include(item_4.name)
          expect(response.body).not_to include(item_5.name)

          expect(response.body).not_to include(item_3.name)
          expect(response.body).not_to include(character.name)
          expect(response.body).not_to include(location.name)
        end

        it 'returns an empty array when no items match the query' do
          get api_v1_notebook_items_url(notebook_1, q: 'TEST'), as: :json

          expect(response).to be_successful
          expect(response.body).not_to include(item_1.name)
          expect(response.body).not_to include(item_4.name)
          expect(response.body).not_to include(item_5.name)

          expect(response.body).not_to include(item_3.name)
          expect(response.body).not_to include(character.name)
          expect(response.body).not_to include(location.name)
        end

        it 'returns all items when all match the query' do
          get api_v1_notebook_items_url(notebook_1, q: 'Item'), as: :json

          expect(response).to be_successful
          expect(response.body).to include(item_1.name)
          expect(response.body).to include(item_4.name)
          expect(response.body).to include(item_5.name)

          expect(response.body).not_to include(item_3.name)
          expect(response.body).not_to include(character.name)
          expect(response.body).not_to include(location.name)
        end

        it 'ignores case when searching' do
          get api_v1_notebook_items_url(notebook_1, q: 'aNoThEr'), as: :json

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
end
