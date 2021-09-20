# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    user
    question
  end
end
