# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/notes', type: :request do
  let!(:notebook_1) { FactoryBot.create(:notebook) }
  let!(:notebook_2) { FactoryBot.create(:notebook) }

  let!(:note_1) { FactoryBot.create(:note, notebook: notebook_1, contents: 'Note 1') }
  let!(:note_2) { FactoryBot.create(:note, notebook: notebook_2, contents: 'Note 2') }

  let(:valid_attributes) { FactoryBot.attributes_for(:note, notebook: notebook_1, contents: 'New Note') }
  let(:invalid_attributes) { FactoryBot.attributes_for(:note, notebook: nil) }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'scopes response to currently viewed notebook' do
      get notebook_notes_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(note_1.contents)
      expect(response.body).not_to include(note_2.contents)
      expect(response.body).not_to include(valid_attributes[:contents])
    end
  end

  describe 'GET /show' do
    it 'renders a successful response when note is linked to given notebook' do
      get notebook_note_url(notebook_1, note_1), as: :json

      expect(response).to be_successful
      expect(response.body).to include(note_1.contents)
      expect(response.body).not_to include(note_2.contents)
      expect(response.body).not_to include(valid_attributes[:contents])
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys only the requested note' do
      expect do
        delete notebook_note_url(notebook_1, note_1), headers: valid_headers, as: :json
      end.to change(Note, :count).by(-1)
    end
  end
end
