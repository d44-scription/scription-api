require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let!(:user) { FactoryBot.build(:user) }

    it 'is valid when attributes are correct' do
      expect(user).to have(0).errors_on(:email)
      expect(user).to have(0).errors_on(:password)
      expect(user).to have(0).errors_on(:password_confirmation)
      expect(user).to have(0).errors_on(:display_name)
      expect(user).to be_valid
    end

    it 'is valid without an email' do
      user.email = nil

      expect(user).to have(1).errors_on(:email)
      expect(user).to have(0).errors_on(:password)
      expect(user).to have(0).errors_on(:password_confirmation)
      expect(user).to have(0).errors_on(:display_name)
      expect(user).not_to be_valid
    end
  end

  describe 'relationships' do
    let!(:user) { FactoryBot.create(:user) }

    it 'successfully creates and destroys an associated notebook' do
      expect do
        user.notebooks.create(name: 'Test Notebook')
      end.to change(user.notebooks, :count).by(1)

      expect do
        user.destroy
      end.to change(Notebook, :count).by(-1)
    end
  end
end
