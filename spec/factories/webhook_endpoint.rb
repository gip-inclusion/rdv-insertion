FactoryBot.define do
  factory :webhook_endpoint do
    url { "http://test-departement/api/v1/webhook" }
    secret { "secret" }
  end
end
