# frozen_string_literal: true

FactoryBot.define do
  factory :notable do
    sequence(:name) { |n| "Noteable #{n}" }
    notebook

    trait :item do
      type { 'Item' }
    end
  end
end
