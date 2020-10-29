# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/notebooks/:id/items', type: :request do
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
end
