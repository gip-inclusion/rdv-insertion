FactoryBot.define do
  factory :motif do
    sequence(:rdv_solidarites_motif_id)
    name { "RSA orientation sur site" }
    category { "rsa_orientation" }
    location_type { "public_office" }
    organisation { create(:organisation) }
  end
end
