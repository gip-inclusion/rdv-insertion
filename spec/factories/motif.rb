FactoryBot.define do
  factory :motif do
    motif_category
    sequence(:rdv_solidarites_motif_id) { |n| n + Process.pid }
    name { "RSA orientation sur site" }
    location_type { "public_office" }
    organisation
    collectif { false }
    default_duration_in_min { 30 }
    min_public_booking_delay { 3.days.to_i }
    max_public_booking_delay { 1.month.to_i }
  end
end
