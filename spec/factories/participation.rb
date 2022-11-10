FactoryBot.define do
  factory :participation do
    association :applicant
    association :rdv
    sequence(:rdv_solidarites_participation_id)

    after(:build) do |participation|
      next if participation.status.present?

      participation.status = rdv.status
    end
  end
end
