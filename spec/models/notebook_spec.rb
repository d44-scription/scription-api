# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notebook, type: :model do
  let!(:notebook) { FactoryBot.build(:notebook) }

  it 'is valid when attributes are correct' do
    expect(notebook).to have(0).errors_on(:name)
    expect(notebook).to be_valid
  end

  it 'is not valid when no name provided' do
    notebook.name = nil

    expect(notebook).to have(1).errors_on(:name)
    expect(notebook).not_to be_valid
  end
end
