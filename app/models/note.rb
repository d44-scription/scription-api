# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :notebook
  has_and_belongs_to_many :notables

  before_validation :clear_notables
  before_validation :link_characters
  before_validation :link_items
  before_validation :link_locations

  validate :permitted_notables
  validates :notebook, presence: true
  validates :content, presence: true, length: { in: 5..500 }

  def regex_for(trigger)
    /#{trigger}\[[^#{trigger}]*\]\(#{trigger}\d\)/
  end

  def trim_for_id(code, trigger)
    code.gsub(/#{trigger}\[[^#{trigger}]*\]\(#{trigger}/, '').delete(')')
  end

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
    character_codes = content ? content.scan(regex_for(Character::TRIGGER)) : []

    character_codes.each do |c|
      # Remove the text surrounding the id
      id = trim_for_id(c, Character::TRIGGER)

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

  def link_items
    # Find all matching instances of the regex
    item_codes = content ? content.scan(regex_for(Item::TRIGGER)) : []

    item_codes.each do |c|
      # Remove the text surrounding the id
      id = trim_for_id(c, Item::TRIGGER)

      # Find the item
      item = notebook.items.find_by(id: id)

      if item
        # Link the item to the notebook without saving
        association(:notables).add_to_target(item)
      else
        errors.add(:items, "must be from this notebook")
      end
    end
  end

  def link_locations
    # Find all matching instances of the regex
    location_codes = content ? content.scan(regex_for(Location::TRIGGER)) : []

    location_codes.each do |c|
      # Remove the text surrounding the id
      id = trim_for_id(c, Location::TRIGGER)

      # Find the location
      location = notebook.locations.find_by(id: id)

      if location
        # Link the location to the notebook without saving
        association(:notables).add_to_target(location)
      else
        errors.add(:locations, "must be from this notebook")
      end
    end
  end
end
