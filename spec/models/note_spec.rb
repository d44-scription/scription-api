# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  let!(:notebook) { FactoryBot.create(:notebook) }
  let!(:note) { FactoryBot.build(:note, notebook: notebook, content: '1' * Note::CHARACTER_LIMIT) }

  it 'is valid when attributes are correct' do
    expect(note).to have(0).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)

    expect(note).to be_valid
  end

  it 'is not valid when no content provided' do
    note.content = nil

    expect(note).to have(2).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)

    expect(note.errors.full_messages).to contain_exactly('Content can\'t be blank', 'Content is too short (minimum is 5 characters)')
    expect(note).not_to be_valid
  end

  it 'is not valid when no notebook provided' do
    note.notebook = nil

    expect(note).to have(0).errors_on(:content)
    expect(note).to have(2).errors_on(:notebook)

    expect(note.errors.full_messages).to contain_exactly('Notebook must exist', 'Notebook can\'t be blank', 'Order index can\'t be blank')
    expect(note).not_to be_valid
  end

  it 'is not valid when content is too short' do
    note.content = '1'

    expect(note).to have(1).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)

    expect(note.errors.full_messages).to contain_exactly('Content is too short (minimum is 5 characters)')
    expect(note).not_to be_valid
  end

  it 'is not valid when content is too long' do
    note.content = '1' * (Note::CHARACTER_LIMIT + 1)

    expect(note).to have(1).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)

    expect(note.errors.full_messages).to contain_exactly("Content is too long (maximum is #{Note::CHARACTER_LIMIT} characters)")
    expect(note).not_to be_valid
  end

  describe 'with notables' do
    let!(:notebook_2) { FactoryBot.create(:notebook) }

    # Confirm regex matches id's longer than 1 character
    let!(:character_1) { FactoryBot.create(:character, id: 150, notebook: notebook) }
    let!(:character_2) { FactoryBot.create(:character, notebook: notebook_2) }

    let!(:item_1) { FactoryBot.create(:item, notebook: notebook) }
    let!(:item_2) { FactoryBot.create(:item, notebook: notebook_2) }

    let!(:location_1) { FactoryBot.create(:location, notebook: notebook) }
    let!(:location_2) { FactoryBot.create(:location, notebook: notebook_2) }

    it 'is valid when notables are from same notebook' do
      note.content = "@[#{character_1.name}](@#{character_1.id}):[#{item_1.name}](:#{item_1.id})#[#{location_1.name}](##{location_1.id})"

      expect(note).to have(0).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)

      expect(note).to have(0).errors_on(:characters)
      expect(note).to have(0).errors_on(:items)
      expect(note).to have(0).errors_on(:locations)

      expect(note).to be_valid
      note.save

      expect(character_1.notes).to contain_exactly(note)
      expect(item_1.notes).to contain_exactly(note)
      expect(location_1.notes).to contain_exactly(note)
    end

    it 'is not valid when characters belong to a different notebook' do
      note.content = "@[#{character_2.name}](@#{character_2.id})"

      expect(note).to have(0).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)
      expect(note).to have(1).errors_on(:characters)

      expect(note.errors.full_messages).to contain_exactly('Characters must be from this notebook')
      expect(note).not_to be_valid
    end

    it 'is not valid when items belong to a different notebook' do
      note.content = ":[#{item_2.name}](:#{item_2.id})"

      expect(note).to have(0).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)
      expect(note).to have(1).errors_on(:items)

      expect(note.errors.full_messages).to contain_exactly('Items must be from this notebook')
      expect(note).not_to be_valid
    end

    it 'is not valid when locations belong to a different notebook' do
      note.content = "#[#{location_2.name}](##{location_2.id})"

      expect(note).to have(0).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)
      expect(note).to have(1).errors_on(:locations)

      expect(note.errors.full_messages).to contain_exactly('Locations must be from this notebook')
      expect(note).not_to be_valid
    end

    it 'is valid when content includes [] only in links' do
      content = "Not@e content @@ @[#{character_1.name}](@#{character_1.id}) ::[#{item_1.name}](:#{item_1.id}) ####  # # #[#{location_1.name}](##{location_1.id})"
      note.content = content

      expect(note).to have(0).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)

      expect(note).to have(0).errors_on(:characters)
      expect(note).to have(0).errors_on(:items)
      expect(note).to have(0).errors_on(:locations)

      expect(note.errors.full_messages).to be_empty
      expect(note).to be_valid
      expect(note.content).to eql(content)
    end

    it 'is not valid when content includes [ outside of links' do
      content = "Note #@: @[#{character_1.name}](@#{character_1.id})[ @:[#{item_1.name}](:#{item_1.id})[####[#{location_1.name}](##{location_1.id})"
      note.content = content

      expect(note).to have(1).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)

      expect(note).to have(0).errors_on(:characters)
      expect(note).to have(0).errors_on(:items)
      expect(note).to have(0).errors_on(:locations)

      expect(note.errors.full_messages).to contain_exactly('Content cannot include square bracket characters')
      expect(note).not_to be_valid
      expect(note.content).to eql(content)
    end

    it 'is not valid when content includes ] outside of links' do
      content = "Note @ @[#{character_1.name}](@#{character_1.id})]:[#{item_1.name}](:#{item_1.id})#[#{location_1.name}](##{location_1.id})@"
      note.content = content

      expect(note).to have(1).errors_on(:content)
      expect(note).to have(0).errors_on(:notebook)

      expect(note).to have(0).errors_on(:characters)
      expect(note).to have(0).errors_on(:items)
      expect(note).to have(0).errors_on(:locations)

      expect(note.errors.full_messages).to contain_exactly('Content cannot include square bracket characters')
      expect(note).not_to be_valid
      expect(note.content).to eql(content)
    end

    it 'correctly sets order index when no other notes are in this notebook' do
      expect(note.order_index).to be_nil

      note.save

      expect(note).to have(0).errors_on(:order_index)
      expect(note.order_index).to eql(0)
      expect(note).to be_valid
    end

    it 'correctly sets order index in sequence' do
      note_2 = FactoryBot.create(:note, notebook: notebook)
      expect(note.order_index).to be_nil
      expect(note_2.order_index).to eql(0)

      note.save

      expect(note).to have(0).errors_on(:order_index)
      expect(note.order_index).to eql(1)
      expect(note_2.order_index).to eql(0)
      expect(note).to be_valid
    end
  end

  describe 'linking hook' do
    let!(:notebook_2) { FactoryBot.create(:notebook) }

    describe 'when linking characters' do
      # Confirm regex matches id's longer than 1 character
      let!(:character_1) { FactoryBot.create(:character, id: 150, notebook: notebook) }
      let!(:character_2) { FactoryBot.create(:character, notebook: notebook) }
      let!(:character_3) { FactoryBot.create(:character, notebook: notebook_2) }

      let!(:character_1_content) { "@[#{character_1.name}](@#{character_1.id})" }
      let!(:character_2_content) { "@[#{character_2.name}](@#{character_2.id})" }
      let!(:character_3_content) { "@[#{character_3.name}](@#{character_3.id})" }

      it 'correctly links to multiple characters' do
        note.update(content: "This is a note for #{character_1_content} and (#{character_2_content})")

        expect(note).to be_valid
        expect(note.notables.count).to eql 2

        expect(note.notables.pluck(:id)).to contain_exactly(character_1.id, character_2.id)
        expect(note.notables.pluck(:name)).to contain_exactly(character_1.name, character_2.name)

        expect(character_1.notes).to contain_exactly(note)
        expect(character_2.notes).to contain_exactly(note)
        expect(character_3.notes.length).to eql 0
      end

      it 'returns an error when linking a character from a different notebook' do
        note.update(content: "This is a note for #{character_3_content}")

        expect(note.notables.count).to eql 0
        expect(note.errors.full_messages).to include('Characters must be from this notebook')

        expect(character_1.notes.length).to eql 0
        expect(character_2.notes.length).to eql 0
        expect(character_3.notes.length).to eql 0
      end
    end

    describe 'when linking items' do
      # Confirm regex matches id's longer than 1 character
      let!(:item_1) { FactoryBot.create(:item, id: 150, notebook: notebook) }
      let!(:item_2) { FactoryBot.create(:item, notebook: notebook) }
      let!(:item_3) { FactoryBot.create(:item, notebook: notebook_2) }

      let!(:item_1_content) { ":[#{item_1.name}](:#{item_1.id})" }
      let!(:item_2_content) { ":[#{item_2.name}](:#{item_2.id})" }
      let!(:item_3_content) { ":[#{item_3.name}](:#{item_3.id})" }

      it 'correctly links to multiple items' do
        note.update(content: "This is a note for #{item_1_content} and (#{item_2_content})")

        expect(note).to be_valid
        expect(note.notables.count).to eql 2

        expect(note.notables.pluck(:id)).to contain_exactly(item_1.id, item_2.id)
        expect(note.notables.pluck(:name)).to contain_exactly(item_1.name, item_2.name)

        expect(item_1.notes).to contain_exactly(note)
        expect(item_2.notes).to contain_exactly(note)
        expect(item_3.notes.length).to eql 0
      end

      it 'returns an error when linking a item from a different notebook' do
        note.update(content: "This is a note for #{item_3_content}")

        expect(note.notables.count).to eql 0
        expect(note.errors.full_messages).to include('Items must be from this notebook')

        expect(item_1.notes.length).to eql 0
        expect(item_2.notes.length).to eql 0
        expect(item_3.notes.length).to eql 0
      end
    end

    describe 'when linking locations' do
      # Confirm regex matches id's longer than 1 character
      let!(:location_1) { FactoryBot.create(:location, id: 150, notebook: notebook) }
      let!(:location_2) { FactoryBot.create(:location, notebook: notebook) }
      let!(:location_3) { FactoryBot.create(:location, notebook: notebook_2) }

      let!(:location_1_content) { "#[#{location_1.name}](##{location_1.id})" }
      let!(:location_2_content) { "#[#{location_2.name}](##{location_2.id})" }
      let!(:location_3_content) { "#[#{location_3.name}](##{location_3.id})" }

      it 'correctly links to multiple locations' do
        note.update(content: "This is a note for #{location_1_content} and (#{location_2_content})")

        expect(note).to be_valid
        expect(note.notables.count).to eql 2

        expect(note.notables.pluck(:id)).to contain_exactly(location_1.id, location_2.id)
        expect(note.notables.pluck(:name)).to contain_exactly(location_1.name, location_2.name)

        expect(location_1.notes).to contain_exactly(note)
        expect(location_2.notes).to contain_exactly(note)
        expect(location_3.notes.length).to eql 0
      end

      it 'returns an error when linking a location from a different notebook' do
        note.update(content: "This is a note for #{location_3_content}")

        expect(note.notables.count).to eql 0
        expect(note.errors.full_messages).to include('Locations must be from this notebook')

        expect(location_1.notes.length).to eql 0
        expect(location_2.notes.length).to eql 0
        expect(location_3.notes.length).to eql 0
      end
    end

    describe 'when linking multiple types of notable' do
      let!(:character) { FactoryBot.create(:character, id: 150, notebook: notebook) }
      let!(:item) { FactoryBot.create(:item, notebook: notebook) }
      let!(:location) { FactoryBot.create(:location, notebook: notebook) }

      let!(:character_content) { "@[#{character.name}](@#{character.id})" }
      let!(:item_content) { ":[#{item.name}](:#{item.id})" }
      let!(:location_content) { "#[#{location.name}](##{location.id})" }

      it 'is successfully linked to all notables' do
        note.update(content: "This is a note for #{character_content}, who visited #{location_content} and recovered #{item_content}")

        expect(note).to be_valid
        expect(note.notables.count).to eql 3

        expect(note.notables.pluck(:id)).to contain_exactly(character.id, item.id, location.id)
        expect(note.notables.pluck(:name)).to contain_exactly(character.name, item.name, location.name)

        expect(character.notes).to contain_exactly(note)
        expect(item.notes).to contain_exactly(note)
        expect(location.notes).to contain_exactly(note)
      end
    end

    describe 'when changing contents to remove links' do
      let!(:character) { FactoryBot.create(:character, notebook: notebook) }
      let!(:item) { FactoryBot.create(:item, notebook: notebook) }
      let!(:location) { FactoryBot.create(:location, notebook: notebook) }

      let!(:character_content) { "@[#{character.name}](@#{character.id})" }
      let!(:item_content) { ":[#{item.name}](:#{item.id})" }
      let!(:location_content) { "#[#{location.name}](##{location.id})" }

      it 'is successfully removes links to unused notables' do
        note.update(content: "This is a note for #{character_content}")

        expect(note.notables.count).to eql 1

        expect(note.notables.pluck(:id)).to contain_exactly(character.id)
        expect(note.notables.pluck(:name)).to contain_exactly(character.name)

        expect(character.notes).to contain_exactly(note)

        note.update(content: "#{item_content} can be found at #{location_content}")
        note.reload

        expect(note).to be_valid
        expect(note.notables.count).to eql 2

        expect(note.notables.pluck(:id)).to contain_exactly(item.id, location.id)
        expect(note.notables.pluck(:name)).to contain_exactly(item.name, location.name)

        character.reload

        expect(character.notes.length).to eql 0
        expect(item.notes).to contain_exactly(note)
        expect(location.notes).to contain_exactly(note)
      end
    end
  end

  context 'when being destroyed' do
    let!(:item) { FactoryBot.create(:item, notebook: notebook) }

    before do
      note.update(content: item.text_code)
    end

    it 'destroys correctly' do
      expect do
        note.destroy
      end.to change(Note, :count).by(-1)
    end

    it 'does not destroy linked notables' do
      expect(item.notes.count).to eql(1)

      expect do
        note.destroy
      end.to change(Notable, :count).by(0)
    end

    it 'destroys linked relationships' do
      expect(item.notes.count).to eql(1)

      expect do
        note.destroy
      end.to change(item.notes, :count).by(-1)
    end
  end
end
