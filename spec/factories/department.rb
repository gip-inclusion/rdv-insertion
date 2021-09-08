FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Departement n°#{n}" }
    sequence(:number)
    sequence(:rdv_solidarites_organisation_id)
    sequence(:capital) { |n| "Capitale n°#{n}" }

    after(:create) do |department|
      create(:configuration, department: department)
    end
  end
end
