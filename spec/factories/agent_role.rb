FactoryBot.define do
  factory :agent_role do
    association :organisation
    association :agent
    level { "basic" }
    sequence(:rdv_solidarites_agent_role_id)
  end
end
