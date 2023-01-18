FactoryBot.define do
  factory :configuration do
    sheet_name { "LISTE DEMANDEURS" }
    invitation_formats { %w[sms] }
    motif_category { "rsa_orientation" }
  end
end
