FactoryBot.define do
  factory :orientation do
    association :user
    association :organisation
    association :agent
    orientation_type { "social" }
  end
end
