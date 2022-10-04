FactoryBot.define do
  factory :lieu do
    sequence(:rdv_solidarites_lieu_id)
    organisation { create(:organisation) }
  end
end
