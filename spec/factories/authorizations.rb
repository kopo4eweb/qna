FactoryBot.define do
  factory :authorization do
    user { nil }
    provider { "facebook" }
    uid { "123456" }
  end
end
