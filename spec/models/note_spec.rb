# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  let!(:notebook) { FactoryBot.create(:notebook) }
  let!(:note) { FactoryBot.build(:note, notebook: notebook) }

  it 'is valid when attributes are correct' do
    expect(note).to have(0).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)

    expect(note).to be_valid
  end

  it 'is not valid when no content provided' do
    note.content = nil

    expect(note).to have(2).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)

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

    expect(note.errors.full_messages).to include('Content is too short (minimum is 5 characters)')
    expect(note).not_to be_valid
  end

  it 'is not valid when content is too long' do
    note.content = '1' * 501

    expect(note).to have(1).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)

    expect(note.errors.full_messages).to include('Content is too long (maximum is 500 characters)')
    expect(note).not_to be_valid
  end

  describe 'linking to notables' do
    let!(:notebook_2) { FactoryBot.create(:notebook) }

    let!(:character_1) { FactoryBot.create(:notable, :character, notebook: notebook) }
    let!(:character_2) { FactoryBot.create(:notable, :character, notebook: notebook) }
    let!(:character_3) { FactoryBot.create(:notable, :character, notebook: notebook_2) }

    let!(:character_1_content) { "@[#{character_1.name}](@#{character_1.id})"}
    let!(:character_2_content) { "@[#{character_2.name}](@#{character_2.id})"}
    let!(:character_3_content) { "@[#{character_3.name}](@#{character_3.id})"}

    it 'correctly links to characters' do
      note.content = "This is a note for #{character_1_content} and (#{character_2_content})"

      note.save

      expect(note).to be_valid

      raise character_1.notes.inspect
      expect(note.notables.count).to eql 2

      expect(note.notables.pluck(:id)).to include(character_1.id)
      expect(note.notables.pluck(:name)).to include(character_1.name)

      expect(note.notables.pluck(:id)).to include(character_2.id)
      expect(note.notables.pluck(:name)).to include(character_2.name)

      expect(note.notables.pluck(:id)).not_to include(character_3.id)
      expect(note.notables.pluck(:name)).not_to include(character_3.name)
    end

    it 'returns an error when linking a character from a different notebook' do
      note.content = "This is a note for #{character_3_content}"

      expect(note).not_to be_valid
      expect(note.notables.count).to eql 0
      expect(note.errors.full_messages).to include("Characters must be from this notebook")

      expect(note.notables.pluck(:id)).not_to include(character_1.id)
      expect(note.notables.pluck(:name)).not_to include(character_1.name)

      expect(note.notables.pluck(:id)).not_to include(character_2.id)
      expect(note.notables.pluck(:name)).not_to include(character_2.name)

      expect(note.notables.pluck(:id)).not_to include(character_3.id)
      expect(note.notables.pluck(:name)).not_to include(character_3.name)
    end
  end
end
