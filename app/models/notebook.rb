# frozen_string_literal: true

class Notebook < ApplicationRecord
  has_many :notes
  has_many :items

  validates :name, presence: true
end
