# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/notebooks/:id/items', type: :request do
  let!(:notebook_1) { FactoryBot.create(:notebook) }
  let!(:notebook_2) { FactoryBot.create(:notebook) }

  let!(:item_1) { FactoryBot.create(:notable, :item, notebook: notebook_1, name: 'Item 1') }
  let!(:item_2) { FactoryBot.create(:notable, :item, notebook: notebook_2, name: 'Item 2') }
  let!(:character) { FactoryBot.create(:notable, :character, notebook: notebook_1, name: 'Character') }
  let!(:location) { FactoryBot.create(:notable, :location, notebook: notebook_1, name: 'Location') }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe 'GET /index' do
    it 'scopes response to currently viewed notebook' do
      get api_v1_notebook_items_url(notebook_1), headers: valid_headers, as: :json

      expect(response).to be_successful
      expect(response.body).to include(item_1.name)

      expect(response.body).not_to include(item_2.name)
      expect(response.body).not_to include(character.name)
      expect(response.body).not_to include(location.name)
    end
  end
end
