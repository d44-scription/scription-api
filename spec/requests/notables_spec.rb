# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/notables', type: :request do
  let!(:notebook_1) { FactoryBot.create(:notebook) }

  let!(:item) { FactoryBot.create(:notable, :item, notebook: notebook_1, name: 'Item') }
  let!(:character) { FactoryBot.create(:notable, :item, notebook: notebook_1, name: 'Character') }
  let!(:location) { FactoryBot.create(:notable, :item, notebook: notebook_1, name: 'Location') }

  let(:item_attributes) { FactoryBot.attributes_for(:notable, :item, notebook: notebook_1) }
  let(:character_attributes) { FactoryBot.attributes_for(:notable, :character, notebook: notebook_1) }
  let(:location_attributes) { FactoryBot.attributes_for(:notable, :location, notebook: notebook_1) }

  let!(:invalid_notebook) { FactoryBot.create(:notebook) }
  let!(:invalid_item) { FactoryBot.create(:notable, :item, notebook: invalid_notebook, name: 'Other Item') }

  let(:invalid_attributes) { FactoryBot.attributes_for(:notable, :item, type: nil) }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'retrieves all notables for current notebook' do
      get api_v1_notebook_notables_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(item.name)
      expect(response.body).to include(character.name)
      expect(response.body).to include(location.name)

      expect(response.body).to include('type')

      expect(response.body).not_to include(invalid_item.name)
      expect(response.body).not_to include(item_attributes[:name])
      expect(response.body).not_to include(character_attributes[:name])
      expect(response.body).not_to include(location_attributes[:name])
    end
  end

  describe 'GET /notes' do
    let!(:note_1) { FactoryBot.create(:note, notebook: notebook_1, content: "Note 1 :[#{item.name}](:#{item.id})")}
    let!(:note_2) { FactoryBot.create(:note, notebook: notebook_1, content: "Note 2 :[#{item.name}](:#{item.id})")}

    it 'retrieves all notes for current notable' do
      get notes_api_v1_notebook_notable_path(notebook_1, item), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(note_1.content)
      expect(response.body).to include(note_2.content)

      expect(response.body).to include('success_message')
      expect(response.body).to include("Note linked to: #{item.name}")

      expect(response.body).not_to include(invalid_item.name)
      expect(response.body).not_to include(character.name)
      expect(response.body).not_to include(location.name)

      expect(response.body).not_to include(item_attributes[:name])
      expect(response.body).not_to include(character_attributes[:name])
      expect(response.body).not_to include(location_attributes[:name])
    end
  end

  describe 'GET /show' do
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

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Item' do
        expect do
          post api_v1_notebook_notables_url(notebook_1),
               params: item_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.items, :count).by(1)
      end

      it 'creates a new Character' do
        expect do
          post api_v1_notebook_notables_url(notebook_1),
               params: character_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.characters, :count).by(1)
      end

      it 'creates a new Location' do
        expect do
          post api_v1_notebook_notables_url(notebook_1),
               params: location_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.locations, :count).by(1)
      end

      it 'renders a JSON response with the new notable' do
        post api_v1_notebook_notables_url(notebook_1),
             params: item_attributes, headers: valid_headers, as: :json

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
      it 'does not create a new notable' do
        expect do
          post api_v1_notebook_notables_url(notebook_1),
               params: invalid_attributes, as: :json
        end.to change(Item, :count).by(0)
      end

      it 'renders a JSON response with errors for the new notable' do
        post api_v1_notebook_notables_url(notebook_1),
             params: invalid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        expect(response.body).to include('Type must be one of Item/Character/Location')
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { FactoryBot.attributes_for(:notable, :item, name: 'Updated Item') }

      it 'updates the requested item' do
        expect do
          patch api_v1_notebook_notable_url(notebook_1, item),
                params: new_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.items, :count).by(0)

        item.reload
        expect(item.name).to eql('Updated Item')
      end

      it 'renders a JSON response with the item' do
        expect do
          patch api_v1_notebook_notable_url(notebook_1, item),
                params: new_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.items, :count).by(0)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the note' do
        expect do
          patch api_v1_notebook_notable_url(notebook_1, item),
                params: invalid_attributes, headers: valid_headers, as: :json
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
    it 'destroys only the requested note' do
      expect do
        delete api_v1_notebook_notable_url(notebook_1, item), headers: valid_headers, as: :json
      end.to change(notebook_1.notables, :count).by(-1)
    end
  end
end
