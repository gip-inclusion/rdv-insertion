FactoryBot.define do
  factory :invitation do
    rdv_solidarites_token { "some_token" }
    link { "https://www.rdv_solidarites.com/some_params" }
    format { :sms }
    department
    user
    help_phone_number { "0139393939" }
    valid_until { 1.week.from_now }
    rdv_context
    organisations { [create(:organisation)] }
  end
end
