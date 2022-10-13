FactoryBot.define do
  factory :notification do
    event { "rdv_created" }
    format { "sms" }
    rdv { create(:rdv) }
    applicant { create(:applicant) }
  end
end
