# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :notebook

  validates :contents, presence: true, length: { in: 5..500 }
end
