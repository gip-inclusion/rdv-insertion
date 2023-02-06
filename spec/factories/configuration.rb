FactoryBot.define do
  factory :configuration do
    association :motif_category
    sheet_name { "LISTE DEMANDEURS" }
    invitation_formats { %w[sms] }
  end
end
