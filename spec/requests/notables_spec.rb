# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/notables', type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:notebook_1) { FactoryBot.create(:notebook, user: user) }

  let!(:item) { FactoryBot.create(:item, notebook: notebook_1, name: 'Item') }
  let!(:character) { FactoryBot.create(:item, notebook: notebook_1, name: 'Character') }
  let!(:location) { FactoryBot.create(:item, notebook: notebook_1, name: 'Location') }

  let(:item_attributes) { FactoryBot.attributes_for(:item, notebook: notebook_1) }
  let(:character_attributes) { FactoryBot.attributes_for(:character, notebook: notebook_1) }
  let(:location_attributes) { FactoryBot.attributes_for(:location, notebook: notebook_1) }

  let!(:invalid_notebook) { FactoryBot.create(:notebook, user: user) }
  let!(:invalid_item) { FactoryBot.create(:item, notebook: invalid_notebook, name: 'Other Item') }

  let(:invalid_attributes) { FactoryBot.attributes_for(:item, type: nil) }

  describe 'GET /index' do
    it 'is prohibited when not signed in' do
      get api_v1_notebook_notables_url(notebook_1), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'retrieves all notables for current notebook' do
        get api_v1_notebook_notables_url(notebook_1), as: :json

        expect(response).to be_successful
        expect(response.body).to include(item.name)
        expect(response.body).to include(item.order_index.to_s)
        expect(response.body).to include(character.name)
        expect(response.body).to include(character.order_index.to_s)
        expect(response.body).to include(location.name)
        expect(response.body).to include(location.order_index.to_s)

        expect(response.body).to include('type')

        expect(response.body).not_to include(invalid_item.name)
        expect(response.body).not_to include(item_attributes[:name])
        expect(response.body).not_to include(character_attributes[:name])
        expect(response.body).not_to include(location_attributes[:name])
      end
    end
  end

  describe 'GET /notes' do
    let!(:note_1) { FactoryBot.create(:note, notebook: notebook_1, content: "Note 1 :[#{item.name}](:#{item.id})") }
    let!(:note_2) { FactoryBot.create(:note, notebook: notebook_1, content: "Note 2 :[#{item.name}](:#{item.id})") }
    let!(:note_3) { FactoryBot.create(:note, notebook: notebook_1, content: "Note 3 :[#{item.name}](:#{item.id}) :[#{item.name}](:#{item.id}) :[#{item.name}](:#{item.id})") }

    it 'is prohibited when not signed in' do
      get notes_api_v1_notebook_notable_url(notebook_1, item), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'retrieves all notes for current notable' do
        get notes_api_v1_notebook_notable_url(notebook_1, item), as: :json

        expect(response).to be_successful
        expect(response.body).to include(note_1.content)
        expect(response.body).to include(note_2.content)
        expect(response.body.scan(note_3.content)).to have_exactly(1).items

        expect(response.body).to include('success_message')
        expect(response.body).to include("Note linked to: #{item.name}")

        expect(response.body).not_to include(invalid_item.name)
        expect(response.body).not_to include(character.name)
        expect(response.body).not_to include(location.name)

        expect(response.body).not_to include(item_attributes[:name])
        expect(response.body).not_to include(character_attributes[:name])
        expect(response.body).not_to include(location_attributes[:name])
      end

      it 'retrieves notes in correct order' do
        note_1.update(order_index: 50)

        get notes_api_v1_notebook_notable_url(notebook_1, item), as: :json

        expect(response).to be_successful
        expect(response.body).to include(note_1.content)
        expect(response.body).to include(note_2.content)

        json = JSON.parse(response.body)

        expect(json.first['content']).to eql(note_2.content)
        expect(json.second['content']).to eql(note_3.content)
        expect(json.third['content']).to eql(note_1.content)
      end
    end
  end

  describe 'GET /show' do
    it 'is prohibited when not signed in' do
      get api_v1_notebook_notable_url(notebook_1, item), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'renders a successful response when note is linked to given notebook' do
        get api_v1_notebook_notable_url(notebook_1, item), as: :json

        expect(response).to be_successful
        expect(response.body).to include(item.name)
        expect(response.body).not_to include(character.name)
        expect(response.body).not_to include(location.name)

        expect(response.body).not_to include('type')

        expect(response.body).not_to include(invalid_item.name)
        expect(response.body).not_to include(item_attributes[:name])
        expect(response.body).not_to include(character_attributes[:name])
        expect(response.body).not_to include(location_attributes[:name])
      end
    end
  end

  describe 'POST /create' do
    it 'is prohibited when not signed in' do
      expect do
        post api_v1_notebook_notables_url(notebook_1),
             params: item_attributes, as: :json
      end.to change(notebook_1.items, :count).by(0)

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      context 'with valid parameters' do
        it 'creates a new Item' do
          expect do
            post api_v1_notebook_notables_url(notebook_1),
                 params: item_attributes, as: :json
          end.to change(notebook_1.items, :count).by(1)
        end

        it 'creates a new Character' do
          expect do
            post api_v1_notebook_notables_url(notebook_1),
                 params: character_attributes, as: :json
          end.to change(notebook_1.characters, :count).by(1)
        end

        it 'creates a new Location' do
          expect do
            post api_v1_notebook_notables_url(notebook_1),
                 params: location_attributes, as: :json
          end.to change(notebook_1.locations, :count).by(1)
        end

        it 'renders a JSON response with the new notable' do
          post api_v1_notebook_notables_url(notebook_1),
               params: item_attributes, as: :json

          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including('application/json'))

          expect(response.body).not_to include(item.name)
          expect(response.body).not_to include(character.name)
          expect(response.body).not_to include(location.name)

          expect(response.body).not_to include(invalid_item.name)

          expect(response.body).to include(item_attributes[:name])
          expect(response.body).to include(item_attributes[:description])
        end
      end

      context 'with invalid parameters' do
        before do
          post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
        end

        it 'does not create a new notable' do
          expect do
            post api_v1_notebook_notables_url(notebook_1),
                 params: invalid_attributes, as: :json
          end.to change(Item, :count).by(0)
        end

        it 'renders a JSON response with errors for the new notable' do
          post api_v1_notebook_notables_url(notebook_1),
               params: invalid_attributes, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json; charset=utf-8')

          expect(response.body).to include('Type must be one of Item/Character/Location')
        end
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { FactoryBot.attributes_for(:item, name: 'Updated Item') }

      it 'is prohibited when not signed in' do
        expect do
          patch api_v1_notebook_notable_url(notebook_1, item),
                params: new_attributes, as: :json
        end.to change(notebook_1.items, :count).by(0)

        item.reload
        expect(item.name).not_to eql('Updated Item')

        expect(response).to be_unauthorized
        expect(response.body).to include('Not Authenticated')
      end

      context 'when signed in' do
        before do
          post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
        end

        it 'updates the requested item' do
          expect do
            patch api_v1_notebook_notable_url(notebook_1, item),
                  params: new_attributes, as: :json
          end.to change(notebook_1.items, :count).by(0)

          item.reload
          expect(item.name).to eql('Updated Item')
        end

        it 'renders a JSON response with the item' do
          expect do
            patch api_v1_notebook_notable_url(notebook_1, item),
                  params: new_attributes, as: :json
          end.to change(notebook_1.items, :count).by(0)

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end
    end

    context 'with invalid parameters' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'renders a JSON response with errors for the note' do
        expect do
          patch api_v1_notebook_notable_url(notebook_1, item),
                params: invalid_attributes, as: :json
        end.to change(notebook_1.items, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        item.reload
        expect(item.name).to eql('Item')

        expect(response.body).to include('Type must be one of Item/Character/Location')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'is prohibited when not signed in' do
      expect do
        delete api_v1_notebook_notable_url(notebook_1, item), as: :json
      end.to change(notebook_1.notables, :count).by(0)

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'destroys only the requested note' do
        expect do
          delete api_v1_notebook_notable_url(notebook_1, item), as: :json
        end.to change(notebook_1.notables, :count).by(-1)
      end
    end
  end
end
