# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/characters', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  let!(:notebook_1) { FactoryBot.create(:notebook, user: user) }
  let!(:notebook_2) { FactoryBot.create(:notebook, user: user) }

  let!(:character_1) { FactoryBot.create(:character, notebook: notebook_1, name: 'Character 1') }
  let!(:character_2) { FactoryBot.create(:character, notebook: notebook_1, name: 'Character 2') }
  let!(:character_3) { FactoryBot.create(:character, notebook: notebook_2, name: 'Character 3') }
  let!(:item) { FactoryBot.create(:item, notebook: notebook_1, name: 'Item') }
  let!(:location) { FactoryBot.create(:location, notebook: notebook_1, name: 'Location') }

  describe 'GET /index' do
    it 'is prohibited when not signed in' do
      get api_v1_notebook_characters_url(notebook_1), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'scopes response to currently viewed notebook' do
        get api_v1_notebook_characters_url(notebook_1), as: :json

        expect(response).to be_successful
        expect(response.body).to include(character_1.name)
        expect(response.body).to include(character_1.text_code)

        expect(response.body).to include(character_2.name)
        expect(response.body).to include(character_2.text_code)

        expect(response.body).not_to include(character_3.name)
        expect(response.body).not_to include(item.name)
        expect(response.body).not_to include(location.name)
      end

      it 'correctly sorts characters alphabetically' do
        character_1.update(name: 'zz_character')

        get api_v1_notebook_characters_url(notebook_1), as: :json

        expect(response).to be_successful
        expect(response.body).to include(character_1.name)
        expect(response.body).to include(character_2.name)

        json = JSON.parse(response.body)

        expect(json.first['name']).to eql(character_2.name)
        expect(json.second['name']).to eql(character_1.name)
      end

      describe 'when searching' do
        let!(:character_4) { FactoryBot.create(:character, notebook: notebook_1, name: 'Different Character') }
        let!(:character_5) { FactoryBot.create(:character, notebook: notebook_1, name: 'Another Character') }

        it 'returns a subset of characters matching the search query' do
          get api_v1_notebook_characters_url(notebook_1, q: 'Different'), as: :json

          expect(response).to be_successful
          expect(response.body).not_to include(character_1.name)
          expect(response.body).to include(character_4.name)
          expect(response.body).not_to include(character_5.name)

          expect(response.body).not_to include(character_3.name)
          expect(response.body).not_to include(item.name)
          expect(response.body).not_to include(location.name)
        end

        it 'returns an empty array when no characters match the query' do
          get api_v1_notebook_characters_url(notebook_1, q: 'TEST'), as: :json

          expect(response).to be_successful
          expect(response.body).not_to include(character_1.name)
          expect(response.body).not_to include(character_4.name)
          expect(response.body).not_to include(character_5.name)

          expect(response.body).not_to include(character_3.name)
          expect(response.body).not_to include(item.name)
          expect(response.body).not_to include(location.name)
        end

        it 'returns all characters when all match the query' do
          get api_v1_notebook_characters_url(notebook_1, q: 'Character'), as: :json

          expect(response).to be_successful
          expect(response.body).to include(character_1.name)
          expect(response.body).to include(character_4.name)
          expect(response.body).to include(character_5.name)

          expect(response.body).not_to include(character_3.name)
          expect(response.body).not_to include(item.name)
          expect(response.body).not_to include(location.name)
        end

        it 'ignores case when searching' do
          get api_v1_notebook_characters_url(notebook_1, q: 'aNoThEr'), as: :json

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
end
