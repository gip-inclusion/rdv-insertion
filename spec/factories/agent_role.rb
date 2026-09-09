FactoryBot.define do
  factory :agent_role do
    organisation
    agent
    access_level { "basic" }
    authorized_to_export_csv { false }
  end
end
