FactoryBot.define do
  factory :reward do
    title { "My reward" }
    image { Rack::Test::UploadedFile.new("#{Rails.root}/spec/files/reward.png") }
    question { nil }
    user_id { nil }
  end
end
