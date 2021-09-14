FactoryBot.define do
  factory :invitation do
    token { "some_token" }
    link { "https://www.rdv_solidarites.com/some_params" }
    format { :sms }
  end
  factory :email_invitation do
    token { "some_token" }
    link { "https://www.rdv_solidarites.com/some_params" }
    format { :email }
  end
end
