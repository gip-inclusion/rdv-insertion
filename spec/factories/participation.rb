FactoryBot.define do
  factory :participation do
    applicant { create(:applicant) }
    rdv { create(:rdv) }
    rdv_context { create(:rdv_context) }
    sequence(:rdv_solidarites_participation_id)

    after(:build) do |participation|
      participation.status = participation.rdv.status if participation.status.blank?
    end
  end
end
