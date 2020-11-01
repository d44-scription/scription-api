# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/notes', type: :request do
  let!(:notebook_1) { FactoryBot.create(:notebook) }
  let!(:notebook_2) { FactoryBot.create(:notebook) }

  let!(:note_1) { FactoryBot.create(:note, notebook: notebook_1, content: 'Note 1') }
  let!(:note_2) { FactoryBot.create(:note, notebook: notebook_2, content: 'Note 2') }

  let(:valid_attributes) { FactoryBot.attributes_for(:note, notebook: notebook_1, content: 'New Note') }
  let(:invalid_attributes) { FactoryBot.attributes_for(:note, content: nil) }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'scopes response to currently viewed notebook' do
      get api_v1_notebook_notes_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(note_1.content)
      expect(response.body).not_to include(note_2.content)
      expect(response.body).not_to include(valid_attributes[:content])
    end
  end

  describe 'GET /show' do
    it 'renders a successful response when note is linked to given notebook' do
      get api_v1_notebook_note_url(notebook_1, note_1), as: :json

      expect(response).to be_successful
      expect(response.body).to include(note_1.content)
      expect(response.body).not_to include(note_2.content)
      expect(response.body).not_to include(valid_attributes[:content])
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Note' do
        expect do
          post api_v1_notebook_notes_url(notebook_1),
               params: valid_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.notes, :count).by(1)
      end

      it 'renders a JSON response with the new note' do
        post api_v1_notebook_notes_url(notebook_1),
             params: valid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))

        expect(response.body).not_to include(note_1.content)
        expect(response.body).not_to include(note_2.content)
        expect(response.body).to include(valid_attributes[:content])
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Note' do
        expect do
          post api_v1_notebook_notes_url(notebook_1),
               params: invalid_attributes, as: :json
        end.to change(Note, :count).by(0)
      end

      it 'renders a JSON response with errors for the new note' do
        post api_v1_notebook_notes_url(notebook_1),
             params: invalid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        expect(response.body).to include('Content can\'t be blank')
        expect(response.body).to include('Content is too short (minimum is 5 characters)')
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { FactoryBot.attributes_for(:note, notebook: notebook_1, content: 'Updated Note') }

      it 'updates the requested note' do
        expect do
          patch api_v1_notebook_note_url(notebook_1, note_1),
                params: new_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.notes, :count).by(0)

        note_1.reload
        expect(note_1.content).to eql('Updated Note')
      end

      it 'renders a JSON response with the note' do
        expect do
          patch api_v1_notebook_note_url(notebook_1, note_1),
                params: new_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.notes, :count).by(0)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the note' do
        expect do
          patch api_v1_notebook_note_url(notebook_1, note_1),
                params: invalid_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.notes, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        note_1.reload
        expect(note_1.content).to eql('Note 1')

        expect(response.body).to include('Content can\'t be blank')
        expect(response.body).to include('Content is too short (minimum is 5 characters)')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys only the requested note' do
      expect do
        delete api_v1_notebook_note_url(notebook_1, note_1), headers: valid_headers, as: :json
      end.to change(Note, :count).by(-1)
    end
  end
end
