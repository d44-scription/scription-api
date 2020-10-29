# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/notebooks/:id/characters', type: :request do
  let!(:notebook_1) { FactoryBot.create(:notebook) }
  let!(:notebook_2) { FactoryBot.create(:notebook) }

  let!(:character_1) { FactoryBot.create(:notable, :character, notebook: notebook_1, name: 'character 1') }
  let!(:character_2) { FactoryBot.create(:notable, :character, notebook: notebook_2, name: 'character 2') }
  let!(:item) { FactoryBot.create(:notable, :item, notebook: notebook_2, name: 'Item') }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'scopes response to currently viewed notebook' do
      get notebook_characters_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(character_1.name)
      expect(response.body).not_to include(character_2.name)
      expect(response.body).not_to include(item.name)
    end
  end
end
