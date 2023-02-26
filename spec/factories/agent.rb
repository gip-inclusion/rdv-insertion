FactoryBot.define do
  factory :agent do
    sequence(:email) { |n| "agent#{n}@gouv.fr" }
    sequence(:first_name) { |n| "jane#{n}" }
    sequence(:last_name) { |n| "doe#{n}" }
    sequence(:rdv_solidarites_agent_id)

    transient do
      basic_role_in_organisations { [] }
    end

    transient do
      admin_role_in_organisations { [] }
    end

    after(:create) do |agent, evaluator|
      evaluator.basic_role_in_organisations.each do |organisation|
        create(:agent_role, agent: agent, organisation: organisation)
      end
      evaluator.admin_role_in_organisations.each do |organisation|
        create(:agent_role, :admin, agent: agent, organisation: organisation)
      end
    end
  end
end
