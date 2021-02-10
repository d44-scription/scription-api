# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/notes', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  let!(:notebook_1) { FactoryBot.create(:notebook, user: user) }
  let!(:notebook_2) { FactoryBot.create(:notebook, user: user) }

  let!(:note_1) { FactoryBot.create(:note, notebook: notebook_1, content: 'Note 1') }
  let!(:note_2) { FactoryBot.create(:note, notebook: notebook_2, content: 'Note 2') }
  let!(:note_3) { FactoryBot.create(:note, notebook: notebook_1, content: 'Note 3') }

  let(:valid_attributes) { FactoryBot.attributes_for(:note, notebook: notebook_1, content: 'New Note') }
  let(:invalid_attributes) { FactoryBot.attributes_for(:note, content: nil) }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    { Authorization: "Token #{user.generate_jwt}" }
  end

  describe 'GET /index' do
    it 'is prohibited when not signed in' do
      get api_v1_notebook_notes_url(notebook_1), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    it 'scopes response to currently viewed notebook' do
      get api_v1_notebook_notes_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(note_1.content)
      expect(response.body).to include(note_1.order_index.to_s)

      expect(response.body).to include(note_3.content)
      expect(response.body).to include(note_3.order_index.to_s)

      expect(response.body).not_to include(note_2.content)
      expect(response.body).not_to include(valid_attributes[:content])
    end

    it 'correctly sorts notes by order index' do
      note_1.update(order_index: 50)

      get api_v1_notebook_notes_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(note_1.content)
      expect(response.body).to include(note_3.content)

      json = JSON.parse(response.body)

      expect(json.first['content']).to eql(note_3.content)
      expect(json.second['content']).to eql(note_1.content)
    end
  end

  describe 'GET /show' do
    it 'is prohibited when not signed in' do
      get api_v1_notebook_note_url(notebook_1, note_1), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    it 'renders a successful response when note is linked to given notebook' do
      get api_v1_notebook_note_url(notebook_1, note_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(note_1.content)
      expect(response.body).to include('Note linked to no notables')
      expect(response.body).not_to include(note_2.content)
      expect(response.body).not_to include(note_3.content)
      expect(response.body).not_to include(valid_attributes[:content])
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'is prohibited when not signed in' do
        expect do
          post api_v1_notebook_notes_url(notebook_1),
               params: valid_attributes, as: :json
        end.to change(notebook_1.notes, :count).by(0)

        expect(response).to be_unauthorized
        expect(response.body).to include('Not Authenticated')
      end

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
        expect(response.body).not_to include(note_3.content)
        expect(response.body).to include(valid_attributes[:content])
        expect(response.body).to include('Note linked to no notables')
      end
    end

    context 'with a link to a notable' do
      let(:notable) { FactoryBot.create(:character, notebook: notebook_1) }
      let(:notable_attributes) { FactoryBot.attributes_for(:note, notebook: notebook_1, content: "@[#{notable.name}](@#{notable.id})") }

      it 'creates a new Note' do
        expect do
          post api_v1_notebook_notes_url(notebook_1),
               params: notable_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.notes, :count).by(1)
      end

      it 'renders a JSON response with the new note' do
        post api_v1_notebook_notes_url(notebook_1),
             params: notable_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))

        expect(response.body).not_to include(note_1.content)
        expect(response.body).not_to include(note_2.content)
        expect(response.body).not_to include(note_3.content)
        expect(response.body).to include(notable_attributes[:content])
        expect(response.body).to include("Note linked to: #{notable.name}")

        note = notebook_1.notes.find_by(content: notable_attributes[:content])
        expect(notable.notes).to contain_exactly(note)
      end
    end

    context 'with a link to an invalid notable' do
      let(:notable) { FactoryBot.create(:character, notebook: notebook_2) }
      let(:invalid_attributes) { FactoryBot.attributes_for(:note, notebook: notebook_1, content: "@[#{notable.name}](@#{notable.id})") }

      it 'renders a JSON response with errors for the note' do
        expect do
          post api_v1_notebook_notes_url(notebook_1),
               params: invalid_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.notes, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        expect(response.body).to include('Characters must be from this notebook')
        expect(notable.notes).to be_empty
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

      it 'is prohibited when not signed in' do
        expect do
          patch api_v1_notebook_note_url(notebook_1, note_1),
                params: new_attributes, as: :json
        end.to change(notebook_1.notes, :count).by(0)

        note_1.reload
        expect(note_1.content).not_to eql('Updated Note')

        expect(response).to be_unauthorized
        expect(response.body).to include('Not Authenticated')
      end

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
        expect(response.body).to include(new_attributes[:content])
        expect(response.body).to include('Note linked to no notables')
      end
    end

    context 'with a link to a notable' do
      let(:notable) { FactoryBot.create(:character, notebook: notebook_1) }
      let(:new_attributes) { FactoryBot.attributes_for(:note, notebook: notebook_1, content: "@[#{notable.name}](@#{notable.id})") }

      it 'updates the requested note' do
        expect do
          patch api_v1_notebook_note_url(notebook_1, note_1),
                params: new_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.notes, :count).by(0)

        note_1.reload
        expect(note_1.content).to eql("@[#{notable.name}](@#{notable.id})")
        expect(notable.notes).to contain_exactly(note_1)
      end

      it 'renders a JSON response with the new note' do
        patch api_v1_notebook_note_url(notebook_1, note_1),
              params: new_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))

        expect(response.body).not_to include(note_1.content)
        expect(response.body).not_to include(note_2.content)
        expect(response.body).not_to include(note_3.content)
        expect(response.body).to include(new_attributes[:content])
        expect(response.body).to include("Note linked to: #{notable.name}")

        expect(notable.notes).to contain_exactly(note_1)
      end
    end

    context 'with a link to an invalid notable' do
      let(:notable) { FactoryBot.create(:character, notebook: notebook_2) }
      let(:invalid_attributes) { FactoryBot.attributes_for(:note, notebook: notebook_1, content: "@[#{notable.name}](@#{notable.id})") }

      it 'renders a JSON response with errors for the note' do
        expect do
          patch api_v1_notebook_note_url(notebook_1, note_1),
                params: invalid_attributes, headers: valid_headers, as: :json
        end.to change(notebook_1.notes, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        note_1.reload
        expect(note_1.content).to eql('Note 1')

        expect(response.body).to include('Characters must be from this notebook')
        expect(notable.notes).to be_empty
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
    it 'is prohibited when not signed in' do
      expect do
        delete api_v1_notebook_note_url(notebook_1, note_1), as: :json
      end.to change(Note, :count).by(0)

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    it 'destroys only the requested note' do
      expect do
        delete api_v1_notebook_note_url(notebook_1, note_1), headers: valid_headers, as: :json
      end.to change(Note, :count).by(-1)
    end
  end
end
