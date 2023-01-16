FactoryBot.define do
  factory :participation do
    association :applicant
    association :rdv
    association :rdv_context
    sequence(:rdv_solidarites_participation_id)

    after(:build) do |participation|
      participation.status = participation.rdv.status if participation.status.blank?
    end
  end
end
