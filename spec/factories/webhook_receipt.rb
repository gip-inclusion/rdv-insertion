FactoryBot.define do
  factory :webhook_receipt do
    rdv_solidarites_rdv_id { 33 }
    sent_at { "2021-20-05" }
    association :webhook_endpoint
  end
end
