FactoryBot.define do
  factory :applicant do
    uid { "MyString" }
    rdv_solidarites_user_id { "MyString" }
    affiliation_number { "MyString" }
    role { 1 }
    department { nil }
  end
end
