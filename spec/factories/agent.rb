FactoryBot.define do
  factory :agent do
    sequence(:email) { |n| "agent#{n}@gouv.fr" }
    sequence(:first_name) { |n| "jane#{n}" }
    sequence(:last_name) { |n| "doe#{n}" }
    sequence(:rdv_solidarites_agent_id)
  end
end
