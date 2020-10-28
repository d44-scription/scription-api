# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :notebook
  has_and_belongs_to_many :notables

  validates :notebook, presence: true
  validates :content, presence: true, length: { in: 5..500 }
end
