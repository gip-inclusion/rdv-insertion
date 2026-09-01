FactoryBot.define do
  factory :rdv_solidarites_oauth_token do
    agent
    sequence(:api_token) { |n| "api-token-#{n}" }
    sequence(:refresh_token) { |n| "refresh-token-#{n}" }
  end
end
