FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Departement n°#{n}" }
    sequence(:number)
    sequence(:capital) { |n| "Capitale n°#{n}" }
    sequence(:region) { |n| "Région n°#{n}" }
    pronoun { "le" }

    after(:build) do |department|
      logo_path = Rails.root.join("spec/fixtures/logo.png")
      department.logo.attach(io: File.open(logo_path), filename: "drome.png", content_type: "image/png")
    end
  end
end
