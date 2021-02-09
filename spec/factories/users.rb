FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test-email-#{n}@example.com"}
    password { 'superSecret123!' }
  end
end
