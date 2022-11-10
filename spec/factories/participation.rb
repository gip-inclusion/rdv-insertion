FactoryBot.define do
  factory :participation do
    applicant { create(:applicant) }
    rdv { create(:rdv) }
    sequence(:rdv_solidarites_participation_id)

    after(:build) do |participation|
      next if participation.status.present?

      participation.status = participation.rdv.status
    end
  end
end
