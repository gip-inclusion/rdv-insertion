FactoryBot.define do
  factory :archive do
    association :department
    association :applicant
  end
end
