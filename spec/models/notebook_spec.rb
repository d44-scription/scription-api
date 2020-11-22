# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notebook, type: :model do
  describe 'validations' do
    let!(:notebook) { FactoryBot.build(:notebook) }

    it 'is valid when attributes are correct' do
      expect(notebook).to have(0).errors_on(:name)
      expect(notebook).to have(0).errors_on(:summary)
      expect(notebook).to be_valid
    end

    it 'is valid without a summary' do
      notebook.summary = nil

      expect(notebook).to have(0).errors_on(:name)
      expect(notebook).to have(0).errors_on(:summary)
      expect(notebook).to be_valid
    end

    it 'correctly sets order index when no other notebooks are available' do
      expect(notebook.order_index).to be_nil

      notebook.save

      expect(notebook).to have(0).errors_on(:order_index)
      expect(notebook.order_index).to eql(0)
      expect(notebook).to be_valid
    end

    it 'correctly sets order index in sequence' do
      notebook_2 = FactoryBot.create(:notebook)
      expect(notebook.order_index).to be_nil
      expect(notebook_2.order_index).to eql(0)

      notebook.save

      expect(notebook).to have(0).errors_on(:order_index)
      expect(notebook.order_index).to eql(1)
      expect(notebook_2.order_index).to eql(0)
      expect(notebook).to be_valid
    end

    it 'is not valid when no name provided' do
      notebook.name = nil

      expect(notebook).to have(1).errors_on(:name)
      expect(notebook).to have(0).errors_on(:summary)
      expect(notebook).not_to be_valid
    end

    it 'is not valid when name is greater than 30 chars' do
      notebook.name = '0' * 31

      expect(notebook).to have(1).errors_on(:name)
      expect(notebook).to have(0).errors_on(:summary)
      expect(notebook).not_to be_valid
    end

    it 'is not valid when summary is greater than 250 chars' do
      notebook.summary = '0' * 251

      expect(notebook).to have(0).errors_on(:name)
      expect(notebook).to have(1).errors_on(:summary)
      expect(notebook).not_to be_valid
    end
  end

  describe 'relationships' do
    let!(:notebook) { FactoryBot.create(:notebook) }

    it 'successfully creates and destroys an associated note' do
      expect do
        notebook.notes.create(content: 'Test Note')
      end.to change(notebook.notes, :count).by(1)

      expect do
        notebook.destroy
      end.to change(Notebook, :count).by(-1)
    end

    it 'successfully creates and destroys an associated item' do
      expect do
        notebook.items.create(name: 'Test Item')
      end.to change(notebook.items, :count).by(1)

      expect do
        notebook.destroy
      end.to change(Notebook, :count).by(-1)
    end

    it 'successfully creates and destroys an associated character' do
      expect do
        notebook.characters.create(name: 'Test Character')
      end.to change(notebook.characters, :count).by(1)

      expect do
        notebook.destroy
      end.to change(Notebook, :count).by(-1)
    end

    it 'successfully creates and destroys an associated location' do
      expect do
        notebook.locations.create(name: 'Test Location')
      end.to change(notebook.locations, :count).by(1)

      expect do
        notebook.destroy
      end.to change(Notebook, :count).by(-1)
    end
  end
end
