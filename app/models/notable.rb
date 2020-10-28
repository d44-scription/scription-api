# frozen_string_literal: true

class Notable < ApplicationRecord
  has_and_belongs_to_many :notes

  validate :permitted_type

  TYPES = %w[item]

  private

  def permitted_type
    unless TYPES.include?(type)
      errors.add(:type, "must be one of #{TYPES.join('/')}")
    end
  end
end
