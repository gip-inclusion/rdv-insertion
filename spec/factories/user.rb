FactoryBot.define do
  factory :user do
    sequence(:uid) { |n| "uid#{n}" }
    sequence(:rdv_solidarites_user_id)
    sequence(:affiliation_number) { |n| "numero_#{n}" }
    department_internal_id { rand(4000..5000).to_s }
    role { "demandeur" }
    title { "monsieur" }
    sequence(:first_name) { |n| "john#{n}" }
    sequence(:last_name) { |n| "doe#{n}" }
    sequence(:email) { |n| "johndoe#{n}@yahoo.fr" }
    address { "27 avenue de Ségur 75007 Paris" }
    phone_number { "+33782605941" }
    created_at { Time.zone.parse("24/12/2O22 22:22") }
    created_through { "rdv_insertion_upload_page" }
    created_from_structure { association :organisation }
    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end
    trait :with_valid_nir do
      birth_date { "1985-01-01" }
      nir { "185027800608443" }
      title { "monsieur" }
    end
  end
end
