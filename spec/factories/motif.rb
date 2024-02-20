FactoryBot.define do
  factory :motif do
    motif_category
    sequence(:rdv_solidarites_motif_id)
    name { "RSA orientation sur site" }
    location_type { "public_office" }
    organisation
    collectif { false }
  end
end
