# frozen_string_literal: true

class Notable < ApplicationRecord
  has_and_belongs_to_many :notes
  belongs_to :notebook

  validate :permitted_type
  validates :type, presence: true
  validates :notebook, presence: true
  validates :name, presence: true
  validates :order_index, presence: true, uniqueness: { scope: :notebook }

  before_validation(on: :create) { set_order_index }

  TYPES = %w[Item Character Location].freeze

  def text_code
    raise 'This should be overriden by subclasses'
  end

  private

  def set_order_index
    self.order_index = notebook ? (notebook.notables.pluck(:order_index).max || -1) + 1 : nil
  end

  def permitted_type
    errors.add(:type, "must be one of #{TYPES.join('/')}") unless TYPES.include?(type)
  end
end
