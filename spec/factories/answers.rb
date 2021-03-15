# frozen_string_literal: true

FactoryBot.define do
  sequence :body do |n|
    "MyText #{n} Answer"
  end

  factory :answer do
    body
    question
    user

    trait :invalid do
      body { nil }
      question
      user
    end
  end
end
