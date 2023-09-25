FactoryBot.define do
  factory :archive do
    association :department
    association :user
  end
end
