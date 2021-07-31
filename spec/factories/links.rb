FactoryBot.define do
  factory :link do
    sequence(:name) { |n| "Link#{n}" }
    url { 'http://google.com' }
    linkable factory: :question
  end
end
