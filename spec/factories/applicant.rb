FactoryBot.define do
  factory :applicant do
    sequence(:uid) { |n| "uid#{n}" }
    sequence(:rdv_solidarites_user_id)
    affiliation_number { "1234" }
    role { 1 }
    title { "monsieur" }
    sequence(:first_name) { |n| "john#{n}" }
    sequence(:last_name) { |n| "doe#{n}" }
    sequence(:email) { |n| "johndoe#{n}@yahoo.fr" }
    address { "27 avenue de Ségur 75007 Paris" }
    phone_number_formatted { "+33782605941" }
    department { create(:department) }
  end
end
