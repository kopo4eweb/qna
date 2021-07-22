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

    trait :with_attachment do
      after(:create) do |question|
        file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/rails_helper.rb")
        question.files.attach(io: file, filename: 'rails_helper.rb')
      end
    end
  end
end
