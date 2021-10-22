FactoryBot.define do
  factory :organisation do
    sequence(:name) { |n| "Departement n°#{n}" }
    sequence(:number)
    sequence(:rdv_solidarites_organisation_id)
    sequence(:capital) { |n| "Capitale n°#{n}" }

    after(:create) do |organisation|
      organisation.configuration ||= create(:configuration, organisation: organisation)
    end
  end
end
