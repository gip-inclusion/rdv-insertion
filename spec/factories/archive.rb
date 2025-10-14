FactoryBot.define do
  factory :archive do
    organisation
    user { create(:user, organisations: [organisation]) }
  end
end
