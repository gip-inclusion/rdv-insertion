FactoryBot.define do
  factory :rdv do
    sequence(:uuid) { |n| "uid#{n}" }
    sequence(:rdv_solidarites_rdv_id)
    starts_at { 3.days.from_now }
    duration_in_min { 30 }
    organisation { create(:organisation) }
    motif { create(:motif) }
    status { "unknown" }
    created_by { "user" }

    after(:build) do |rdv|
      if rdv.participations.blank?
        rdv.applicants = [create(:applicant)]
        rdv.participations.first.rdv_context = create(:rdv_context)
        rdv.participations.first.created_by = "user"
      end
    end
  end
end
