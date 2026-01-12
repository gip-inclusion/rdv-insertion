FactoryBot.define do
  factory :motif do
    motif_category
    sequence(:rdv_solidarites_motif_id) { |n| n + Process.pid }
    name { "RSA orientation sur site" }
    location_type { "public_office" }
    organisation
    collectif { false }
    default_duration_in_min { 30 }
  end
end
