FactoryBot.define do
  factory :link do
    name { 'google' }
    url { 'http://google.com' }
    linkable factory: :question
  end
end
