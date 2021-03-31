# frozen_string_literal: true

FactoryBot.define do
  factory :notable do
    sequence(:name) { |n| "Noteable #{n}" }
    description { 'Description of notable' }
    viewed_at { DateTime.new(1970, 1, 1) }
    notebook

    factory :item, class: Item do
      type { 'Item' }
    end

    factory :character, class: Character do
      type { 'Character' }
    end

    factory :location, class: Location do
      type { 'Location' }
    end
  end
end
