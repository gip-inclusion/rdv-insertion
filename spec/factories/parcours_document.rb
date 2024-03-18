FactoryBot.define do
  factory :parcours_document do
    user
    agent
    document_date { nil }
    department
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/dummy.pdf")) }
  end
end
