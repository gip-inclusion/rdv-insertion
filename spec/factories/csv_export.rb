FactoryBot.define do
  factory :csv_export do
    agent
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/fichier_contact_test.csv")) }
    structure { association(:department) }
    kind { "users_csv" }
  end
end
