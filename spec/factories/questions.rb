# frozen_string_literal: true

FactoryBot.define do
  sequence :title do |n|
    "MyString#{n}"
  end

  sequence :body_question do |n|
    "MyText#{n}"
  end

  factory :question do
    title
    body { generate(:body_question) }
    user

    trait :invalid do
      title { nil }
    end
  end
end
