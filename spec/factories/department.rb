FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Departement n°#{n}" }
    sequence(:number)
    sequence(:capital) { |n| "Capitale n°#{n}" }
    sequence(:region) { |n| "Région n°#{n}" }
    pronoun { "le" }
    logo { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/logo.png")) }

    trait :ft_department do
      number { 83 }
    end
  end
end
