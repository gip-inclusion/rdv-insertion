FactoryBot.define do
  factory :cookies_consent do
    agent
    support_accepted { false }
    tracking_accepted { false }
  end
end