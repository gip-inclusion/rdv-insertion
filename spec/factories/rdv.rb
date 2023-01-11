FactoryBot.define do
  factory :rdv do
    sequence(:uuid) { |n| "uid#{n}" }
    sequence(:rdv_solidarites_rdv_id)
    starts_at { 3.days.from_now }
    duration_in_min { 30 }
    organisation { create(:organisation) }
    motif { create(:motif) }
    status { "unknown" }

    after(:build) do |rdv|
      if rdv.applicants.blank? && rdv.participations.blank?
        rdv.applicants = [create(:applicant)]
        rdv.participations.first.rdv_context = create(:rdv_context)
      end
    end
  end
end
