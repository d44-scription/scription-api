# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks', type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:existing_notebook) { FactoryBot.create(:notebook, user: user) }
  let!(:existing_notebook_2) { FactoryBot.create(:notebook) }

  let(:valid_attributes) { FactoryBot.attributes_for(:notebook, user: user) }
  let(:invalid_attributes) { FactoryBot.attributes_for(:notebook, user: user, name: '0' * 46) }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotebooksController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
  { 'Authorization': "Token #{user.generate_jwt}" }
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      get api_v1_notebooks_url, headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(existing_notebook.name)
      expect(response.body).to include(existing_notebook.summary)
      expect(response.body).to include(existing_notebook.order_index.to_s)

      # Confirm response is scoped to current user & only includes created books
      expect(response.body).not_to include(valid_attributes[:name])
      expect(response.body).not_to include(existing_notebook_2.name)
    end
  end

  describe 'GET /show' do
    let!(:note) { FactoryBot.create(:note, notebook: existing_notebook) }

    it 'renders a successful response' do
      get api_v1_notebook_url(existing_notebook), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(existing_notebook.name)
      expect(response.body).to include(note.content)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Notebook' do
        expect do
          post api_v1_notebooks_url,
               params: valid_attributes, headers: valid_headers, as: :json
        end.to change(user.notebooks, :count).by(1)
      end

      it 'renders a JSON response with the new notebook' do
        post api_v1_notebooks_url,
             params: valid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Notebook' do
        expect do
          post api_v1_notebooks_url,
               params: invalid_attributes, as: :json
        end.to change(user.notebooks, :count).by(0)
      end

      it 'renders a JSON response with errors for the new notebook' do
        post api_v1_notebooks_url,
             params: invalid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        expect(response.body).to include('Name is too long (maximum is 45 characters)')
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { FactoryBot.attributes_for(:notebook, name: 'Updated Notebook', summary: 'Updated Summary') }

      it 'updates the requested notebook' do
        patch api_v1_notebook_url(existing_notebook),
              params: new_attributes, headers: valid_headers, as: :json

        existing_notebook.reload
        expect(existing_notebook.name).to eql('Updated Notebook')
        expect(existing_notebook.summary).to eql('Updated Summary')
      end

      it 'renders a JSON response with the notebook' do
        patch api_v1_notebook_url(existing_notebook),
              params: new_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the notebook' do
        patch api_v1_notebook_url(existing_notebook),
              params: invalid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        existing_notebook.reload
        expect(existing_notebook.name).not_to eql('Updated Notebook')
        expect(response.body).to include('Name is too long (maximum is 45 characters)')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested notebook' do
      expect do
        delete api_v1_notebook_url(existing_notebook), headers: valid_headers, as: :json
      end.to change(user.notebooks, :count).by(-1)
    end
  end
end
