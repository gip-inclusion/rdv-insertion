FactoryBot.define do
  factory :motif do
    name { "RSA orientation sur site" }
    category { "rsa_orientation" }
    organisation { create(:organisation) }
  end
end
