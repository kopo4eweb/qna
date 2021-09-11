FactoryBot.define do
  factory :comment do
    body { "My comment text" }
    user { create(:user) }
    commentable factory: :question
  end
end
