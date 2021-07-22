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

    trait :with_attachment do
      after(:create) do |answer|
        file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/rails_helper.rb")
        answer.files.attach(io: file, filename: 'rails_helper.rb')
      end
    end
  end
end
