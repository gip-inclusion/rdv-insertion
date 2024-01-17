FactoryBot.define do
  factory :users_organisation do
    association :user
    association :organisation
  end
end
