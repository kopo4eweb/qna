# frozen_string_literal: true

FactoryBot.define do
  sequence :body do |n|
    "Answer body #{n}"
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

    trait :with_links do
      after(:create) do |question|
        create(:link, linkable: question)
      end
    end

    trait :with_comments do
      after(:create) do |answer|
        create_list(:comment, 3, commentable: answer)
      end
    end
  end
end
