# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/notebooks', type: :request do
  let!(:existing_notebook) { FactoryBot.create(:notebook) }

  let(:valid_attributes) { FactoryBot.attributes_for(:notebook) }
  let(:invalid_attributes) { FactoryBot.attributes_for(:notebook, name: nil) }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotebooksController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      get notebooks_url, headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(existing_notebook.name)
      expect(response.body).not_to include(valid_attributes[:name])
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      get notebook_url(existing_notebook), as: :json

      expect(response).to be_successful
      expect(response.body).to include(existing_notebook.name)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Notebook' do
        expect do
          post notebooks_url,
               params: valid_attributes, headers: valid_headers, as: :json
        end.to change(Notebook, :count).by(1)
      end

      it 'renders a JSON response with the new notebook' do
        post notebooks_url,
             params: valid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Notebook' do
        expect do
          post notebooks_url,
               params: invalid_attributes, as: :json
        end.to change(Notebook, :count).by(0)
      end

      it 'renders a JSON response with errors for the new notebook' do
        post notebooks_url,
             params: invalid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { FactoryBot.attributes_for(:notebook, name: 'Updated Notebook') }

      it 'updates the requested notebook' do
        patch notebook_url(existing_notebook),
              params: new_attributes, headers: valid_headers, as: :json

        existing_notebook.reload
        expect(existing_notebook.name).to eql('Updated Notebook')
      end

      it 'renders a JSON response with the notebook' do
        patch notebook_url(existing_notebook),
              params: new_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the notebook' do
        patch notebook_url(existing_notebook),
              params: invalid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        existing_notebook.reload
        expect(existing_notebook.name).not_to eql('Updated Notebook')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested notebook' do
      expect do
        delete notebook_url(existing_notebook), headers: valid_headers, as: :json
      end.to change(Notebook, :count).by(-1)
    end
  end
end
