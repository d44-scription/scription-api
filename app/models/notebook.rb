# frozen_string_literal: true

class Notebook < ApplicationRecord
  has_many :notes
  has_many :notables
  has_many :items
  has_many :characters

  validates :name, presence: true
end
