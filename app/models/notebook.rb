class Notebook < ApplicationRecord
  validates :name, presence: true
end
