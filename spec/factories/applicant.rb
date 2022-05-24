FactoryBot.define do
  factory :applicant do
    association :department
    sequence(:uid) { |n| "uid#{n}" }
    sequence(:rdv_solidarites_user_id)
    sequence(:affiliation_number) { |n| "numero_#{n}" }
    role { 1 }
    title { "monsieur" }
    sequence(:first_name) { |n| "john#{n}" }
    sequence(:last_name) { |n| "doe#{n}" }
    sequence(:email) { |n| "johndoe#{n}@yahoo.fr" }
    address { "27 avenue de Ségur 75007 Paris" }
    phone_number { "+33782605941" }
    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
