FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Departement n°#{n}" }
    sequence(:number)
    sequence(:rdv_solidarites_organisation_id)
    sequence(:capital) { |n| "Capitale n°#{n}" }
  end
end
