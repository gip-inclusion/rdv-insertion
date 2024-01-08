FactoryBot.define do
  factory :configuration do
    association :organisation
    association :motif_category
    association :file_configuration
    invitation_formats { %w[sms email postal] }
    phone_number { "0101010101" }
  end
end
