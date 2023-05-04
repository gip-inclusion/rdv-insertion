FactoryBot.define do
  factory :configuration do
    association :organisation
    association :motif_category
    association :file_configuration
    invitation_formats { %w[sms email postal] }
  end
end
