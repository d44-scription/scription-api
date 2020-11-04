# frozen_string_literal: true

class Notebook < ApplicationRecord
  has_many :notes, dependent: :destroy
  has_many :notables, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :locations, dependent: :destroy

  validates :name, presence: true
end
