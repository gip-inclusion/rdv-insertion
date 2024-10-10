FactoryBot.define do
  factory :motif_category do
    template
    motif_category_type { "autre" }
    sequence(:short_name) { |n| "rsa_orientation_#{n}" }
    name { "RSA orientation" }
  end
end
