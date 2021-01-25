# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  let!(:notebook) { FactoryBot.create(:notebook) }
  let!(:note) { FactoryBot.build(:note, notebook: notebook) }

  it 'is valid when attributes are correct' do
    expect(note).to have(0).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)
    expect(note).to have(0).errors_on(:notables)

    expect(note).to be_valid
  end

  it 'is not valid when no content provided' do
    note.content = nil

    expect(note).to have(2).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)
    expect(note).to have(0).errors_on(:notables)

    expect(note.errors.full_messages).to include('Content can\'t be blank', 'Content is too short (minimum is 5 characters)')
    expect(note).not_to be_valid
  end

  it 'is not valid when no notebook provided' do
    note.notebook = nil

    expect(note).to have(0).errors_on(:content)
    expect(note).to have(2).errors_on(:notebook)

    expect(note.errors.full_messages).to include('Notebook must exist', 'Notebook can\'t be blank')
    expect(note).not_to be_valid
  end

  it 'is not valid when content is too short' do
    note.content = '1'

    expect(note).to have(1).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)
    expect(note).to have(0).errors_on(:notables)

    expect(note.errors.full_messages).to include('Content is too short (minimum is 5 characters)')
    expect(note).not_to be_valid
  end

  it 'is not valid when content is too long' do
    note.content = '1' * 501

    expect(note).to have(1).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)
    expect(note).to have(0).errors_on(:notables)

    expect(note.errors.full_messages).to include('Content is too long (maximum is 500 characters)')
    expect(note).not_to be_valid
  end

  describe 'with notables' do
    let!(:notebook_2) { FactoryBot.create(:notebook) }

    let!(:character_1) { FactoryBot.create(:notable, :character, notebook: notebook) }
    let!(:character_2) { FactoryBot.create(:notable, :character, notebook: notebook_2) }

    let!(:item_1) { FactoryBot.create(:notable, :item, notebook: notebook) }
    let!(:item_2) { FactoryBot.create(:notable, :item, notebook: notebook_2) }

    let!(:location_1) { FactoryBot.create(:notable, :location, notebook: notebook) }
    let!(:location_2) { FactoryBot.create(:notable, :location, notebook: notebook_2) }

    it 'is valid when notables are from same notebook' do
      note.notables << character_1
      note.notables << item_1
      note.notables << location_1

      expect(note).to have(0).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)
      expect(note).to have(0).errors_on(:notables)

      expect(note).to be_valid
    end

    it 'is not valid when characters belong to a different notebook' do
      note.notables << character_2

      expect(note).to have(0).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)
      expect(note).to have(1).errors_on(:notables)

      expect(note.errors.full_messages).to include('Notables must be from this notebook')
      expect(note).not_to be_valid
    end

    it 'is not valid when items belong to a different notebook' do
      note.notables << item_2

      expect(note).to have(0).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)
      expect(note).to have(1).errors_on(:notables)

      expect(note.errors.full_messages).to include('Notables must be from this notebook')
      expect(note).not_to be_valid
    end

    it 'is not valid when locations belong to a different notebook' do
      note.notables << location_2

      expect(note).to have(0).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)
      expect(note).to have(1).errors_on(:notables)

      expect(note.errors.full_messages).to include('Notables must be from this notebook')
      expect(note).not_to be_valid
    end
  end

  describe 'linking hook' do
    let!(:notebook_2) { FactoryBot.create(:notebook) }

    describe 'when linking characters' do
      let!(:character_1) { FactoryBot.create(:notable, :character, notebook: notebook) }
      let!(:character_2) { FactoryBot.create(:notable, :character, notebook: notebook) }
      let!(:character_3) { FactoryBot.create(:notable, :character, notebook: notebook_2) }

      let!(:character_1_content) { "@[#{character_1.name}](@#{character_1.id})"}
      let!(:character_2_content) { "@[#{character_2.name}](@#{character_2.id})"}
      let!(:character_3_content) { "@[#{character_3.name}](@#{character_3.id})"}

      it 'correctly links to multiple characters' do
        note.content = "This is a note for #{character_1_content} and (#{character_2_content})"

        note.save

        expect(note).to be_valid
        expect(note.notables.count).to eql 2

        expect(note.notables.pluck(:id)).to include(character_1.id)
        expect(note.notables.pluck(:name)).to include(character_1.name)

        expect(note.notables.pluck(:id)).to include(character_2.id)
        expect(note.notables.pluck(:name)).to include(character_2.name)

        expect(note.notables.pluck(:id)).not_to include(character_3.id)
        expect(note.notables.pluck(:name)).not_to include(character_3.name)

        character_1.reload
        character_2.reload
        character_3.reload

        expect(character_1.notes.length).to eql 1
        expect(character_1.notes).to include(note)

        expect(character_2.notes.length).to eql 1
        expect(character_2.notes).to include(note)

        expect(character_3.notes.length).to eql 0
      end

      it 'returns an error when linking a character from a different notebook' do
        note.content = "This is a note for #{character_3_content}"

        expect(note).not_to be_valid
        expect(note.notables.count).to eql 0
        expect(note.errors.full_messages).to include('Characters must be from this notebook')

        expect(note.notables.pluck(:id)).not_to include(character_1.id)
        expect(note.notables.pluck(:name)).not_to include(character_1.name)

        expect(note.notables.pluck(:id)).not_to include(character_2.id)
        expect(note.notables.pluck(:name)).not_to include(character_2.name)

        expect(note.notables.pluck(:id)).not_to include(character_3.id)
        expect(note.notables.pluck(:name)).not_to include(character_3.name)

        character_1.reload
        character_2.reload
        character_3.reload

        expect(character_1.notes.length).to eql 0
        expect(character_2.notes.length).to eql 0
        expect(character_3.notes.length).to eql 0
      end
    end

    describe 'when linking items' do
      let!(:item_1) { FactoryBot.create(:notable, :item, notebook: notebook) }
      let!(:item_2) { FactoryBot.create(:notable, :item, notebook: notebook) }
      let!(:item_3) { FactoryBot.create(:notable, :item, notebook: notebook_2) }

      let!(:item_1_content) { ":[#{item_1.name}](:#{item_1.id})"}
      let!(:item_2_content) { ":[#{item_2.name}](:#{item_2.id})"}
      let!(:item_3_content) { ":[#{item_3.name}](:#{item_3.id})"}

      it 'correctly links to multiple items' do
        note.content = "This is a note for #{item_1_content} and (#{item_2_content})"

        note.save

        expect(note).to be_valid
        expect(note.notables.count).to eql 2

        expect(note.notables.pluck(:id)).to include(item_1.id)
        expect(note.notables.pluck(:name)).to include(item_1.name)

        expect(note.notables.pluck(:id)).to include(item_2.id)
        expect(note.notables.pluck(:name)).to include(item_2.name)

        expect(note.notables.pluck(:id)).not_to include(item_3.id)
        expect(note.notables.pluck(:name)).not_to include(item_3.name)

        item_1.reload
        item_2.reload
        item_3.reload

        expect(item_1.notes.length).to eql 1
        expect(item_1.notes).to include(note)

        expect(item_2.notes.length).to eql 1
        expect(item_2.notes).to include(note)

        expect(item_3.notes.length).to eql 0
      end

      it 'returns an error when linking a item from a different notebook' do
        note.content = "This is a note for #{item_3_content}"

        expect(note).not_to be_valid
        expect(note.notables.count).to eql 0
        expect(note.errors.full_messages).to include('Items must be from this notebook')

        expect(note.notables.pluck(:id)).not_to include(item_1.id)
        expect(note.notables.pluck(:name)).not_to include(item_1.name)

        expect(note.notables.pluck(:id)).not_to include(item_2.id)
        expect(note.notables.pluck(:name)).not_to include(item_2.name)

        expect(note.notables.pluck(:id)).not_to include(item_3.id)
        expect(note.notables.pluck(:name)).not_to include(item_3.name)

        item_1.reload
        item_2.reload
        item_3.reload

        expect(item_1.notes.length).to eql 0
        expect(item_2.notes.length).to eql 0
        expect(item_3.notes.length).to eql 0
      end
    end

    describe 'when linking locations' do
      let!(:location_1) { FactoryBot.create(:notable, :location, notebook: notebook) }
      let!(:location_2) { FactoryBot.create(:notable, :location, notebook: notebook) }
      let!(:location_3) { FactoryBot.create(:notable, :location, notebook: notebook_2) }

      let!(:location_1_content) { "#[#{location_1.name}](##{location_1.id})"}
      let!(:location_2_content) { "#[#{location_2.name}](##{location_2.id})"}
      let!(:location_3_content) { "#[#{location_3.name}](##{location_3.id})"}

      it 'correctly links to multiple locations' do
        note.content = "This is a note for #{location_1_content} and (#{location_2_content})"

        note.save

        expect(note).to be_valid
        expect(note.notables.count).to eql 2

        expect(note.notables.pluck(:id)).to include(location_1.id)
        expect(note.notables.pluck(:name)).to include(location_1.name)

        expect(note.notables.pluck(:id)).to include(location_2.id)
        expect(note.notables.pluck(:name)).to include(location_2.name)

        expect(note.notables.pluck(:id)).not_to include(location_3.id)
        expect(note.notables.pluck(:name)).not_to include(location_3.name)

        location_1.reload
        location_2.reload
        location_3.reload

        expect(location_1.notes.length).to eql 1
        expect(location_1.notes).to include(note)

        expect(location_2.notes.length).to eql 1
        expect(location_2.notes).to include(note)

        expect(location_3.notes.length).to eql 0
      end

      it 'returns an error when linking a location from a different notebook' do
        note.content = "This is a note for #{location_3_content}"

        expect(note).not_to be_valid
        expect(note.notables.count).to eql 0
        expect(note.errors.full_messages).to include('Locations must be from this notebook')

        expect(note.notables.pluck(:id)).not_to include(location_1.id)
        expect(note.notables.pluck(:name)).not_to include(location_1.name)

        expect(note.notables.pluck(:id)).not_to include(location_2.id)
        expect(note.notables.pluck(:name)).not_to include(location_2.name)

        expect(note.notables.pluck(:id)).not_to include(location_3.id)
        expect(note.notables.pluck(:name)).not_to include(location_3.name)

        location_1.reload
        location_2.reload
        location_3.reload

        expect(location_1.notes.length).to eql 0
        expect(location_2.notes.length).to eql 0
        expect(location_3.notes.length).to eql 0
      end
    end

    describe 'when linking multiple types of notable' do
      let!(:character) { FactoryBot.create(:notable, :character, notebook: notebook) }
      let!(:item) { FactoryBot.create(:notable, :item, notebook: notebook) }
      let!(:location) { FactoryBot.create(:notable, :location, notebook: notebook) }

      let!(:character_content) { "@[#{character.name}](@#{character.id})"}
      let!(:item_content) { ":[#{item.name}](:#{item.id})"}
      let!(:location_content) { "#[#{location.name}](##{location.id})"}

      it 'is successfully linked to all notables' do
        note.content = "This is a note for #{character_content}, who visited #{location_content} and recovered #{item_content}"

        note.save

        expect(note).to be_valid
        expect(note.notables.count).to eql 3

        expect(note.notables.pluck(:id)).to include(character.id)
        expect(note.notables.pluck(:name)).to include(character.name)

        expect(note.notables.pluck(:id)).to include(item.id)
        expect(note.notables.pluck(:name)).to include(item.name)

        expect(note.notables.pluck(:id)).to include(location.id)
        expect(note.notables.pluck(:name)).to include(location.name)

        character.reload
        item.reload
        location.reload

        expect(character.notes.length).to eql 1
        expect(character.notes).to include(note)

        expect(item.notes.length).to eql 1
        expect(item.notes).to include(note)

        expect(location.notes.length).to eql 1
        expect(location.notes).to include(note)
      end
    end

    describe 'when changing contents to remove links' do
      let!(:character) { FactoryBot.create(:notable, :character, notebook: notebook) }
      let!(:item) { FactoryBot.create(:notable, :item, notebook: notebook) }
      let!(:location) { FactoryBot.create(:notable, :location, notebook: notebook) }

      let!(:character_content) { "@[#{character.name}](@#{character.id})"}
      let!(:item_content) { ":[#{item.name}](:#{item.id})"}
      let!(:location_content) { "#[#{location.name}](##{location.id})"}

      it 'is successfully removes links to unused notables' do
        note.content = "This is a note for #{character_content}"
        note.save

        expect(note).to be_valid
        expect(note.notables.count).to eql 1

        expect(note.notables.pluck(:id)).to include(character.id)
        expect(note.notables.pluck(:name)).to include(character.name)

        character.reload

        expect(character.notes.length).to eql 1
        expect(character.notes).to include(note)

        note.content = "#{item_content} can be found at #{location_content}"
        note.save

        expect(note).to be_valid
        expect(note.notables.count).to eql 2

        expect(note.notables.pluck(:id)).not_to include(character.id)
        expect(note.notables.pluck(:name)).not_to include(character.name)

        expect(note.notables.pluck(:id)).to include(item.id)
        expect(note.notables.pluck(:name)).to include(item.name)

        expect(note.notables.pluck(:id)).to include(location.id)
        expect(note.notables.pluck(:name)).to include(location.name)

        character.reload
        item.reload
        location.reload

        expect(character.notes.length).to eql 0

        expect(item.notes.length).to eql 1
        expect(item.notes).to include(note)

        expect(location.notes.length).to eql 1
        expect(location.notes).to include(note)
      end
    end
  end
end
