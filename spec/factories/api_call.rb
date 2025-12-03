FactoryBot.define do
  factory :api_call do
    http_method { "GET" }
    path { "/api/v1/users" }
    host { "rdv-insertion.fr" }
    controller_name { "users" }
    action_name { "index" }
    agent { nil }
  end
end
