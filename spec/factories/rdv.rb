FactoryBot.define do
  factory :rdv do
    sequence(:uuid) { |n| "uid#{n}" }
    sequence(:rdv_solidarites_rdv_id)
    starts_at { Time.zone.now + 3.days }
    duration_in_min { 30 }
    sequence(:rdv_solidarites_motif_id)
    department { create(:department) }

    after(:build) do |rdv|
      rdv.applicants = [create(:applicant)]
    end
  end
end
