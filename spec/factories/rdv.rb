FactoryBot.define do
  factory :rdv do
    sequence(:uuid) { |n| "uid#{n}" }
    sequence(:rdv_solidarites_rdv_id)
    starts_at { 3.days.from_now }
    duration_in_min { 30 }
    organisation { create(:organisation) }
    motif { create(:motif) }

    after(:build) do |rdv|
      rdv.applicants = [create(:applicant)]
    end
  end
end
