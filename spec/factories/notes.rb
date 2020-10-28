# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    content { 'Test note content' }
    notebook
  end
end
