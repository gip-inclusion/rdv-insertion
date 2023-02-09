FactoryBot.define do
  factory :motif_category do
    association :template
    sequence(:short_name) { |n| "rsa_orientation_#{n}" }
    name { "RSA orientation" }
  end
end
