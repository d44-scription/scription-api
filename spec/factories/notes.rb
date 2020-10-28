# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    contents { 'Test note contents' }
    notebook
  end
end
