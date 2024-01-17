FactoryBot.define do
  factory :notification do
    association :participation
    event { "participation_created" }
    format { "sms" }
    sequence(:rdv_solidarites_rdv_id)
  end
end
