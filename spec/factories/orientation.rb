FactoryBot.define do
  factory :orientation do
    user
    organisation
    agent
    orientation_type { "social" }
  end
end
