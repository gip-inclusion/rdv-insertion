FactoryBot.define do
  factory :archiving do
    association :department
    association :applicant
  end
end
