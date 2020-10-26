# frozen_string_literal: true

class Notebook < ApplicationRecord
  validates :name, presence: true
end
