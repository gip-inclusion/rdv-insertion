FactoryBot.define do
  factory :notification do
    participation
    event { "participation_created" }
    format { "sms" }
    sequence(:rdv_solidarites_rdv_id) { |n| n + Process.pid }
  end
end
