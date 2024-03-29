# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks', type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:existing_notebook) { FactoryBot.create(:notebook, user: user, name: 'zz_Notebook') }
  let!(:existing_notebook_2) { FactoryBot.create(:notebook, user: user, name: 'aa_Notebook') }

  let!(:other_users_notebook) { FactoryBot.create(:notebook) }
  let(:valid_attributes) { FactoryBot.attributes_for(:notebook, user: user) }
  let(:invalid_attributes) { FactoryBot.attributes_for(:notebook, user: user, name: '0' * 46) }

  describe 'GET /index' do
    it 'is prohibited when not signed in' do
      get api_v1_notebooks_url, as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'renders a successful response' do
        get api_v1_notebooks_url, as: :json

        expect(response).to be_successful
        expect(response.body).to include(existing_notebook.name)
        expect(response.body).to include(existing_notebook.summary)

        expect(response.body).to include(existing_notebook_2.name)
        expect(response.body).to include(existing_notebook_2.summary)

        # Confirm response is scoped to current user & only includes created books
        expect(response.body).not_to include(valid_attributes[:name])
        expect(response.body).not_to include(other_users_notebook.name)
      end

      it 'retrieves notebooks sorted alphabetically' do
        get api_v1_notebooks_url, as: :json

        expect(response).to be_successful
        expect(response.body).to include(existing_notebook.name)
        expect(response.body).to include(existing_notebook.summary)

        expect(response.body).to include(existing_notebook_2.name)
        expect(response.body).to include(existing_notebook_2.summary)

        json = JSON.parse(response.body)

        expect(json.first['name']).to eql(existing_notebook_2.name)
        expect(json.second['name']).to eql(existing_notebook.name)
      end
    end
  end

  describe 'GET /show' do
    let!(:note) { FactoryBot.create(:note, notebook: existing_notebook) }

    it 'is prohibited when not signed in' do
      get api_v1_notebook_url(existing_notebook), as: :json

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'renders a successful response' do
        get api_v1_notebook_url(existing_notebook), as: :json

        expect(response).to be_successful
        expect(response.body).to include(existing_notebook.name)
        expect(response.body).to include(note.content)
      end
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'is prohibited when not signed in' do
        expect do
          post api_v1_notebooks_url,
               params: valid_attributes, as: :json
        end.to change(user.notebooks, :count).by(0)

        expect(response).to be_unauthorized
        expect(response.body).to include('Not Authenticated')
      end

      context 'when signed in' do
        before do
          post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
        end

        it 'creates a new Notebook' do
          expect do
            post api_v1_notebooks_url,
                 params: valid_attributes, as: :json
          end.to change(user.notebooks, :count).by(1)
        end

        it 'renders a JSON response with the new notebook' do
          post api_v1_notebooks_url,
               params: valid_attributes, as: :json

          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end
    end

    context 'with invalid parameters' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'does not create a new Notebook' do
        expect do
          post api_v1_notebooks_url,
               params: invalid_attributes, as: :json
        end.to change(user.notebooks, :count).by(0)
      end

      it 'renders a JSON response with errors for the new notebook' do
        post api_v1_notebooks_url,
             params: invalid_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        expect(response.body).to include('Name is too long (maximum is 45 characters)')
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) { FactoryBot.attributes_for(:notebook, name: 'Updated Notebook', summary: 'Updated Summary') }

      it 'is prohibited when not signed in' do
        expect do
          patch api_v1_notebook_url(existing_notebook),
                params: new_attributes, as: :json
        end.to change(Notebook, :count).by(0)

        existing_notebook.reload
        expect(existing_notebook.name).not_to eql('Updated Notebook')
        expect(existing_notebook.summary).not_to eql('Updated Summary')

        expect(response).to be_unauthorized
        expect(response.body).to include('Not Authenticated')
      end

      context 'when signed in' do
        before do
          post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
        end

        it 'updates the requested notebook' do
          expect do
            patch api_v1_notebook_url(existing_notebook),
                  params: new_attributes, as: :json
          end.to change(Notebook, :count).by(0)

          existing_notebook.reload
          expect(existing_notebook.name).to eql('Updated Notebook')
          expect(existing_notebook.summary).to eql('Updated Summary')
        end

        it 'renders a JSON response with the notebook' do
          patch api_v1_notebook_url(existing_notebook),
                params: new_attributes, as: :json

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end
    end

    context 'with invalid parameters' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'renders a JSON response with errors for the notebook' do
        patch api_v1_notebook_url(existing_notebook),
              params: invalid_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        existing_notebook.reload
        expect(existing_notebook.name).not_to eql('Updated Notebook')
        expect(response.body).to include('Name is too long (maximum is 45 characters)')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'is prohibited when not signed in' do
      expect do
        delete api_v1_notebook_url(existing_notebook), as: :json
      end.to change(user.notebooks, :count).by(0)

      expect(response).to be_unauthorized
      expect(response.body).to include('Not Authenticated')
    end

    context 'when signed in' do
      before do
        post user_session_url, as: :json, params: { user: { email: user.email, password: 'superSecret123!' } }
      end

      it 'destroys the requested notebook' do
        expect do
          delete api_v1_notebook_url(existing_notebook), as: :json
        end.to change(user.notebooks, :count).by(-1)
      end
    end
  end
end
