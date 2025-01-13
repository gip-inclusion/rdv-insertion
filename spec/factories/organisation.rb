FactoryBot.define do
  factory :organisation do
    sequence(:name) { |n| "Organisation n°#{n}" }
    sequence(:email) { |n| "organisation#{n + Process.pid}@rdv-insertion.fr" }
    rdv_solidarites_organisation_id { rand(1..10_000_000_000) }
    department
    phone_number { "0101010101" }
    organisation_type { "conseil_departemental" }

    transient do
      with_dpa_agreement { true }
    end

    after(:build) do |organisation, evaluator|
      if evaluator.with_dpa_agreement && organisation.dpa_agreement.blank?
        organisation.dpa_agreement = DpaAgreement.new(organisation:, agent: create(:agent))
      end
    end

    trait :without_dpa_agreement do
      with_dpa_agreement { false }
    end
  end
end
