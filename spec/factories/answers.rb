# frozen_string_literal: true

FactoryBot.define do
  factory :answer do
    body { 'MyText Answer' }
    question
    user

    trait :invalid do
      body { nil }
      question
      user
    end
  end
end
