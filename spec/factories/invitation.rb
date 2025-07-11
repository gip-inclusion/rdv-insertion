FactoryBot.define do
  factory :invitation do
    rdv_solidarites_token { "some_token" }
    link { "https://www.rdv_solidarites.com/some_params" }
    format { :sms }
    department
    user
    help_phone_number { "0139393939" }
    expires_at { 1.week.from_now }
    follow_up
    rdv_with_referents { false }
    organisations { [create(:organisation)] }

    trait :delivered do
      delivery_status { "delivered" }
      last_brevo_webhook_received_at { Time.zone.now }
    end
  end
end
