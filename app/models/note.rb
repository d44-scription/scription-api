# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :notebook
  has_many :notable_notes, dependent: :destroy
  has_many :notables, through: :notable_notes

  TRIGGERS = [Item::TRIGGER, Character::TRIGGER, Location::TRIGGER].freeze
  CHARACTER_LIMIT = 1000

  validates :notebook, presence: true
  validates :content, presence: true, length: { in: 5..CHARACTER_LIMIT }
  validates :order_index, presence: true, uniqueness: { scope: :notebook }
  validate :link_notables
  validate :forbidden_characters

  before_validation(on: :create) { set_order_index }

  def notable_message
    notables.any? ? "Note linked to: #{notables.pluck(:name).join('/')}" : 'Note linked to no notables'
  end

  private

  def set_order_index
    self.order_index = notebook ? (notebook.notes.pluck(:order_index).max || -1) + 1 : nil
  end

  def regex_for(trigger)
    /#{trigger}\[[^\]]+\]\(#{trigger}\d+\)/
  end

  def trim_for_id(code, trigger)
    code.gsub(/#{trigger}\[[^\]]+\]\(#{trigger}/, '').delete(')')
  end

  def link_notables
    return unless content

    notables.destroy_all

    link_characters if content.match(regex_for(Character::TRIGGER))
    link_items if content.match(regex_for(Item::TRIGGER))
    link_locations if content.match(regex_for(Location::TRIGGER))
  end

  def forbidden_characters
    return unless content

    stripped_content = content.dup

    TRIGGERS.each do |trigger|
      stripped_content.scan(regex_for(trigger)).map { |code| stripped_content.slice!(code) }
    end

    errors.add(:content, 'cannot include square bracket characters') if ['[', ']'].any? { |trigger| stripped_content.include?(trigger) }
  end

  def link_characters
    # Find all matching instances of the regex
    character_codes = content.scan(regex_for(Character::TRIGGER))

    character_codes.each do |c|
      # Remove the text surrounding the id
      id = trim_for_id(c, Character::TRIGGER)

      # Find the character
      character = notebook.characters.find_by(id: id)

      if character
        # Link the character to the notebook
        notables << character
      else
        errors.add(:characters, 'must be from this notebook')
      end
    end
  end

  def link_items
    # Find all matching instances of the regex
    item_codes = content.scan(regex_for(Item::TRIGGER))

    item_codes.each do |c|
      # Remove the text surrounding the id
      id = trim_for_id(c, Item::TRIGGER)

      # Find the item
      item = notebook.items.find_by(id: id)

      if item
        # Link the item to the notebook
        notables << item
      else
        errors.add(:items, 'must be from this notebook')
      end
    end
  end

  def link_locations
    # Find all matching instances of the regex
    location_codes = content.scan(regex_for(Location::TRIGGER))

    location_codes.each do |c|
      # Remove the text surrounding the id
      id = trim_for_id(c, Location::TRIGGER)

      # Find the location
      location = notebook.locations.find_by(id: id)

      if location
        # Link the location to the notebook
        notables << location
      else
        errors.add(:locations, 'must be from this notebook')
      end
    end
  end
end
