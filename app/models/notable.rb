# frozen_string_literal: true

class Notable < ApplicationRecord
  has_and_belongs_to_many :notes
  belongs_to :notebook

  validate :permitted_type
  validates :type, presence: true
  validates :notebook, presence: true
  validates :name, presence: true

  # TODO: Once users are added, ensure this is unique within the scope of each user
  validates :order_index, presence: true, uniqueness: true

  before_validation(on: :create) { set_order_index }

  TYPES = %w[Item Character Location].freeze

  private

  def set_order_index
    # TODO: Once users are added, ensure this retrieves order index from within user scoped
    self.order_index = notebook ? (notebook.notables.pluck(:order_index).max || -1) + 1 : nil
  end

  def permitted_type
    errors.add(:type, "must be one of #{TYPES.join('/')}") unless TYPES.include?(type)
  end
end
