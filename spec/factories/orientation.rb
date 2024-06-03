FactoryBot.define do
  factory :orientation do
    user
    organisation
    agent
    orientation_type { "social" }
    starts_at { Time.zone.now.yesterday }
  end
end
