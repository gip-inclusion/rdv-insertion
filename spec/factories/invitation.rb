FactoryBot.define do
  factory :invitation do
    token { "some_token" }
    link { "https://www.rdv_solidarites.com/some_params" }
    format { :sms }
    organisation { create(:organisation) }
  end
end
