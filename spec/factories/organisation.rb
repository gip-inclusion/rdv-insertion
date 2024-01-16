FactoryBot.define do
  factory :organisation do
    sequence(:name) { |n| "Organisation n°#{n}" }
    sequence(:email) { |n| "organisation#{n}@rdv-insertion.fr" }
    sequence(:rdv_solidarites_organisation_id)
    department { create(:department) }
    phone_number { "0101010101" }
  end
end
