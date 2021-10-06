FactoryBot.define do
  factory :notification do
    event { "rdv_created" }
    association :applicant
  end
end
