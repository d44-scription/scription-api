# frozen_string_literal: true

FactoryBot.define do
  factory :notebook do
    sequence(:name) { |n| "Notebook #{n}" }
  end
end
