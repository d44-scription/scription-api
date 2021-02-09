# frozen_string_literal: true

class Notebook < ApplicationRecord
  belongs_to :user
  with_options dependent: :destroy do |model|
    model.has_many :notes
    model.has_many :notables
    model.has_many :items
    model.has_many :characters
    model.has_many :locations
  end

  validates :name, presence: true, length: { maximum: 45 }
  validates :summary, length: { maximum: 250 }
  # TODO: Once users are added, ensure this is unique within the scope of each user
  validates :order_index, presence: true, uniqueness: true

  before_validation(on: :create) { set_order_index }

  private

  def set_order_index
    # TODO: Once users are added, ensure this retrieves order index from within user scoped
    self.order_index = (Notebook.pluck(:order_index).max || -1) + 1
  end
end
