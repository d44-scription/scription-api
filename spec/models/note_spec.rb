# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  let!(:notebook) { FactoryBot.create(:notebook) }
  let!(:note) { FactoryBot.build(:note, notebook: notebook)}

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

  it 'is not valid when content is too short' do
    note.content = '1' * 501

    expect(note).to have(1).errors_on(:content)
    expect(note).to have(0).errors_on(:notebook)

    expect(note.errors.full_messages).to include('Content is too long (maximum is 500 characters)')
    expect(note).not_to be_valid
  end
end
