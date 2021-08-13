FactoryBot.define do
  factory :comment do
    body { "My comment text" }
    user { nil }
    commentable factory: :question
  end
end
