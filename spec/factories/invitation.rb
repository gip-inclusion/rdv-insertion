FactoryBot.define do
  factory :invitation do
    rdv_solidarites_token { "some_token" }
    link { "https://www.rdv_solidarites.com/some_params" }
    format { :sms }
    number_of_days_to_accept_invitation { 3 }
    department { create(:department) }
    association :applicant
    help_phone_number { "0139393939" }
    valid_until { 1.week.from_now }
    rdv_context { build(:rdv_context) }
    organisations { [create(:organisation)] }
  end
end
