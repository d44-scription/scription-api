# frozen_string_literal: true

class Notebook < ApplicationRecord
  has_many :notes

  validates :name, presence: true
end
