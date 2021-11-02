FactoryBot.define do
  factory :organisation do
    sequence(:name) { |n| "Departement n°#{n}" }
    sequence(:rdv_solidarites_organisation_id)

    department { create(:department) }
    after(:create) do |organisation|
      organisation.configuration ||= create(:configuration, organisation: organisation)
    end
  end
end
