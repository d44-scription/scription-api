# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/notes', type: :request do
  let!(:notebook_1) { FactoryBot.create(:notebook) }
  let!(:notebook_2) { FactoryBot.create(:notebook) }

  let!(:item_1) { FactoryBot.create(:notable, :item, notebook: notebook_1, name: 'Item 1') }
  let!(:item_2) { FactoryBot.create(:notable, :item, notebook: notebook_2, name: 'Item 2') }

  let(:valid_attributes) { FactoryBot.attributes_for(:notable, :item, notebook: notebook_1) }
  let(:invalid_attributes) { FactoryBot.attributes_for(:notable, :item, name: nil, description: 'Description') }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'scopes response to currently viewed notebook' do
      get notebook_items_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(item_1.name)
      expect(response.body).not_to include(item_2.name)
      expect(response.body).not_to include(valid_attributes[:name])
    end
  end

  describe 'GET /show' do
    it 'renders a successful response when note is linked to given notebook' do
      get notebook_item_url(notebook_1, item_1), as: :json

      expect(response).to be_successful
      expect(response.body).to include(item_1.name)
      expect(response.body).not_to include(item_2.name)
      expect(response.body).not_to include(valid_attributes[:name])
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Note' do
        expect do
          post notebook_items_url(notebook_1),
               params: valid_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.items, :count).by(1)
      end

      it 'renders a JSON response with the new note' do
        post notebook_items_url(notebook_1),
             params: valid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))

        expect(response.body).not_to include(item_1.name)
        expect(response.body).not_to include(item_2.name)
        expect(response.body).to include(valid_attributes[:name])
        expect(response.body).to include(valid_attributes[:description])
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Note' do
        expect do
          post notebook_items_url(notebook_1),
               params: invalid_attributes, as: :json
        end.to change(Item, :count).by(0)
      end

      it 'renders a JSON response with errors for the new note' do
        post notebook_items_url(notebook_1),
             params: invalid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        expect(response.body).to include('Name can\'t be blank')
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { FactoryBot.attributes_for(:note, notebook: notebook_1, name: 'Updated Item') }

      it 'updates the requested note' do
        expect do
          patch notebook_item_url(notebook_1, item_1),
                params: new_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.items, :count).by(0)

        item_1.reload
        expect(item_1.name).to eql('Updated Item')
      end

      it 'renders a JSON response with the note' do
        expect do
          patch notebook_item_url(notebook_1, item_1),
                params: new_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.items, :count).by(0)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the note' do
        expect do
          patch notebook_item_url(notebook_1, item_1),
                params: invalid_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.items, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        item_1.reload
        expect(item_1.name).to eql('Item 1')

        expect(response.body).to include('Name can\'t be blank')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys only the requested note' do
      expect do
        delete notebook_item_url(notebook_1, item_1), headers: valid_headers, as: :json
      end.to change(Item, :count).by(-1)
    end
  end
end
