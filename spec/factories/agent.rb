FactoryBot.define do
  factory :agent do
    sequence(:email) { |n| "agent#{n + Process.pid}@gouv.fr" }
    sequence(:first_name) { |n| "jane#{n}" }
    sequence(:last_name) { |n| "doe#{n}" }

    rdv_solidarites_agent_id { rand(1..10_000_000_000) }
    cgu_accepted_at { Time.zone.now }

    transient do
      basic_role_in_organisations { [] }
    end

    transient do
      admin_role_in_organisations { [] }
    end

    transient do
      create_cookies_consent { true }
    end

    trait :without_cookies_consent do
      create_cookies_consent { false }
    end

    trait :super_admin do
      to_create do |instance|
        instance.super_admin = true
        instance.save(validate: false)
      end
    end

    trait :super_admin_verified do
      to_create do |instance|
        instance.super_admin = true
        instance.save(validate: false)
        instance.super_admin_authentication_requests.create!(verified_at: Time.current, token: "123456")
      end
    end

    after(:create) do |agent, evaluator|
      evaluator.basic_role_in_organisations.each do |organisation|
        create(:agent_role, agent: agent, organisation: organisation)
      end
      evaluator.admin_role_in_organisations.each do |organisation|
        create(:agent_role, :admin, agent: agent, organisation: organisation)
      end
      create(:cookies_consent, agent: agent) if evaluator.create_cookies_consent
    end
  end
end
