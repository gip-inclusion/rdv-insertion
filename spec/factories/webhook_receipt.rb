FactoryBot.define do
  factory :webhook_receipt do
    resource_id { 33 }
    resource_model { "Rdv" }
    timestamp { "2021-20-05" }
    association :webhook_endpoint
  end
end
