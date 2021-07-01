FactoryBot.define do
  factory :applicant do
    sequence(:uid) { |n| "uid#{n}" }
    sequence(:rdv_solidarites_user_id)
    affiliation_number { "1234" }
    role { 1 }
    department { create(:department) }
  end
end
