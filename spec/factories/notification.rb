FactoryBot.define do
  factory :convocation do
    event { "rdv_created" }
    applicant { create(:applicant) }
  end
end
