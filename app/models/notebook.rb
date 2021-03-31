# frozen_string_literal: true

class Notebook < ApplicationRecord
  belongs_to :user
  with_options dependent: :destroy do |model|
    model.has_many :notes
    model.has_many :notables
    model.has_many :items
    model.has_many :characters
    model.has_many :locations
  end

  validates :name, presence: true, length: { maximum: 45 }
  validates :summary, length: { maximum: 250 }
end
