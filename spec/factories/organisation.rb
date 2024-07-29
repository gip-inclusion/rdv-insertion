FactoryBot.define do
  factory :organisation do
    sequence(:name) { |n| "Organisation n°#{n}" }
    sequence(:email) { |n| "organisation#{n}@rdv-insertion.fr" }
    rdv_solidarites_organisation_id { rand(1..10_000_000_000) }
    department
    phone_number { "0101010101" }
    organisation_type { "conseil_departemental" }
  end
end
