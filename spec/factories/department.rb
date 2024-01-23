FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Departement n°#{n}" }
    sequence(:number)
    sequence(:capital) { |n| "Capitale n°#{n}" }
    sequence(:region) { |n| "Région n°#{n}" }
    pronoun { "le" }
  end
end
