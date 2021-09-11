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

    trait :with_links do
      after(:create) do |question|
        create(:link, linkable: question)
      end
    end

    trait :with_comments do
      after(:create) do |question|
        create_list(:comment, 3, commentable: question)
      end
    end

    trait :with_answers do
      after(:create) do |question|
        create_list(:answer, 3, question: question)
      end
    end
  end
end
