FactoryBot.define do
  factory :notification do
    event { "rdv_created" }
    applicant { create(:applicant) }
  end
end
