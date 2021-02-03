# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notable, type: :model do
  let!(:notebook) { FactoryBot.create(:notebook) }

  context 'when an undefined notable' do
    let!(:notable) { FactoryBot.build(:notable, notebook: notebook) }

    it 'is not valid without a set type' do
      expect(notable).to have(2).errors_on(:type)

      expect(notable.errors.full_messages).to contain_exactly('Type must be one of Item/Character/Location', 'Type can\'t be blank')
      expect(notable).not_to be_valid
    end

    it 'is not valid an unpermitted type' do
      notable.type = 'Invalid'
      expect(notable).to have(1).errors_on(:type)

      expect(notable.errors.full_messages).to contain_exactly('Type must be one of Item/Character/Location')
      expect(notable).not_to be_valid
    end
  end

  context 'when an item' do
    let!(:item) { FactoryBot.build(:item, notebook: notebook) }

    it 'is valid when attributes are correct' do
      expect(notebook.items).to be_empty

      expect(item).to have(0).errors_on(:type)
      expect(item).to have(0).errors_on(:name)
      expect(item).to have(0).errors_on(:notebook)

      expect(item).to be_valid

      item.save
      expect(notebook.items).not_to be_empty
    end

    it 'is invalid when no name is given' do
      item.name = nil

      expect(item).to have(0).errors_on(:type)
      expect(item).to have(1).errors_on(:name)
      expect(item).to have(0).errors_on(:notebook)

      expect(item.errors.full_messages).to contain_exactly('Name can\'t be blank')
      expect(item).not_to be_valid
    end

    it 'is invalid when no notebook is given' do
      item.notebook = nil

      expect(item).to have(0).errors_on(:type)
      expect(item).to have(0).errors_on(:name)
      expect(item).to have(2).errors_on(:notebook)

      expect(item.errors.full_messages).to contain_exactly('Notebook can\'t be blank', 'Notebook must exist', 'Order index can\'t be blank')
      expect(item).not_to be_valid
    end

    it 'correctly sets order index when no other items are in this notebook' do
      expect(item.order_index).to be_nil

      item.save

      expect(item).to have(0).errors_on(:order_index)
      expect(item.order_index).to eql(0)
      expect(item).to be_valid
    end

    it 'correctly sets order index in sequence' do
      item_2 = FactoryBot.create(:item, notebook: notebook)
      expect(item.order_index).to be_nil
      expect(item_2.order_index).to eql(0)

      item.save

      expect(item).to have(0).errors_on(:order_index)
      expect(item.order_index).to eql(1)
      expect(item_2.order_index).to eql(0)
      expect(item).to be_valid
    end

    it 'correctly sets order index in sequence when different notable types present' do
      location = FactoryBot.create(:location, notebook: notebook)
      character = FactoryBot.create(:character, notebook: notebook)

      expect(item.order_index).to be_nil
      expect(location.order_index).to eql(0)
      expect(character.order_index).to eql(1)

      item.save

      expect(item).to have(0).errors_on(:order_index)
      expect(item.order_index).to eql(2)
      expect(location.order_index).to eql(0)
      expect(character.order_index).to eql(1)
      expect(item).to be_valid
    end

    it 'returns text code with item trigger' do
      item.save

      expect(item.text_code).to eql(":[#{item.name}](:#{item.id})")
    end
  end

  context 'when a character' do
    let!(:character) { FactoryBot.build(:character, notebook: notebook) }

    it 'is valid when attributes are correct' do
      expect(notebook.characters).to be_empty

      expect(character).to have(0).errors_on(:type)
      expect(character).to have(0).errors_on(:name)
      expect(character).to have(0).errors_on(:notebook)

      expect(character).to be_valid

      character.save
      expect(notebook.characters).not_to be_empty
    end

    it 'returns text code with character trigger' do
      character.save

      expect(character.text_code).to eql("@[#{character.name}](@#{character.id})")
    end
  end

  context 'when a location' do
    let!(:location) { FactoryBot.build(:location, notebook: notebook) }

    it 'is valid when attributes are correct' do
      expect(notebook.locations).to be_empty

      expect(location).to have(0).errors_on(:type)
      expect(location).to have(0).errors_on(:name)
      expect(location).to have(0).errors_on(:notebook)

      expect(location).to be_valid

      location.save
      expect(notebook.locations).not_to be_empty
    end

    it 'returns text code with location trigger' do
      location.save

      expect(location.text_code).to eql("#[#{location.name}](##{location.id})")
    end
  end
end
