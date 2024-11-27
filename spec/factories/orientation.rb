FactoryBot.define do
  factory :orientation do
    user
    organisation
    agent
    orientation_type
    starts_at { Time.zone.now.last_month }
    ends_at { Time.zone.now.tomorrow }
  end
end
