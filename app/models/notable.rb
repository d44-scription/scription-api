# frozen_string_literal: true

class Notable < ApplicationRecord
  has_and_belongs_to_many :notes
  belongs_to :notebook

  validate :permitted_type
  validates :type, presence: true
  validates :notebook, presence: true
  validates :name, presence: true

  TYPES = %w[Item].freeze

  private

  def permitted_type
    errors.add(:type, "must be one of #{TYPES.join('/')}") unless TYPES.include?(type)
  end
end
