FactoryBot.define do
  factory :participation do
    user
    rdv
    follow_up
    sequence(:rdv_solidarites_participation_id) { |n| n + Process.pid }

    after(:build) do |participation|
      participation.status = participation.rdv.status if participation.status.blank?
      participation.created_by_type = (participation.rdv.created_by || "user") if participation.created_by_type.blank?
    end
  end
end
