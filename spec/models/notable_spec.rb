# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notable, type: :model do
  let!(:notebook) { FactoryBot.create(:notebook) }

  context 'when an undefined notable' do
    let!(:notable) { FactoryBot.build(:notable, notebook: notebook) }

    it 'is not valid without a set type' do
      expect(notable).to have(2).errors_on(:type)

      expect(notable.errors.full_messages).to include('Type must be one of Item', 'Type can\'t be blank')
      expect(notable).not_to be_valid
    end

    it 'is not valid an unpermitted type' do
      notable.type = 'Invalid'
      expect(notable).to have(1).errors_on(:type)

      expect(notable.errors.full_messages).to include('Type must be one of Item')
      expect(notable).not_to be_valid
    end
  end

  context 'when an item' do
    let!(:item) { FactoryBot.build(:notable, :item, notebook: notebook) }
    it 'is valid when attributes are correct' do
      expect(item).to have(0).errors_on(:type)
      expect(item).to have(0).errors_on(:name)
      expect(item).to have(0).errors_on(:notebook)

      expect(notebook.items).to include(item)
      expect(item).to be_valid
    end

    it 'is invalid when no name is given' do
      item.name = nil

      expect(item).to have(0).errors_on(:type)
      expect(item).to have(1).errors_on(:name)
      expect(item).to have(0).errors_on(:notebook)

      expect(item.errors.full_messages).to include('Name can\'t be blank')
      expect(item).not_to be_valid
    end

    it 'is invalid when no notebook is given' do
      item.notebook = nil

      expect(item).to have(0).errors_on(:type)
      expect(item).to have(0).errors_on(:name)
      expect(item).to have(2).errors_on(:notebook)

      expect(item.errors.full_messages).to include('Notebook can\'t be blank', 'Notebook must exist')
      expect(item).not_to be_valid
    end
  end
end
