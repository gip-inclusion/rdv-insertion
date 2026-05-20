FactoryBot.define do
  factory :creneau_opening_request do
    user_list_upload
    association :recipient_agent, factory: :agent
    users_to_invite_count { 10 }
    available_creneaux_count { 5 }
    link { "https://www.rdv-solidarites.localhost:3000/admin/organisations/1/planning/plage_ouvertures" }
  end
end
