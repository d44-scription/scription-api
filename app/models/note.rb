# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :notebook
  has_and_belongs_to_many :notables

  before_validation :clear_notables
  before_validation :link_characters

  validate :permitted_notables
  validates :notebook, presence: true
  validates :content, presence: true, length: { in: 5..500 }

  # RegEx for the format of a notable:
  # Trigger[Name](Trigger Id)
  CHARACTER_REGEX = /@\[[^@]*\]\(@\d\)/

  private

  def permitted_notables
    errors.add(:notables, "must be from this notebook") if notables.any? do |n|
      n.notebook != notebook
    end
  end

  def clear_notables
    notables = []
  end

  def link_characters
    # Find all matching instances of the regex
    character_codes = content ? content.scan(CHARACTER_REGEX) : []

    character_codes.each do |c|
      # Remove the text surrounding the id
      id = c.gsub(/@\[[^@]*\]\(@/, '').delete(')')

      # Find the character
      character = notebook.characters.find_by(id: id)

      if character
        # Link the character to the notebook without saving
        association(:notables).add_to_target(character)
      else
        errors.add(:characters, "must be from this notebook")
      end
    end
  end
end
