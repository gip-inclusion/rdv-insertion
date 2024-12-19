FactoryBot.define do
  factory :motif_category do
    template
    motif_category_type { "rsa_orientation" }
    sequence(:short_name) { |n| "rsa_orientation_#{n}" }
    name { "RSA orientation" }
  end
end
