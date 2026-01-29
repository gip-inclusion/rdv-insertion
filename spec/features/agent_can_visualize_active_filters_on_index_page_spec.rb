describe "Agents can visualize active filters on index page", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation) }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }
  let!(:user1) { create(:user, first_name: "Bertrand", last_name: "Blier") }
  let!(:user2) { create(:user, first_name: "Amanda", last_name: "Ajer") }
  let!(:user3) { create(:user, first_name: "Claire", last_name: "Casubolo") }

  let!(:users_organisation1) do
    create(:users_organisation, user: user1, organisation: organisation, created_at: Time.zone.now)
  end
  let!(:users_organisation2) do
    create(:users_organisation, user: user2, organisation: organisation, created_at: 1.day.ago)
  end
  let!(:users_organisation3) do
    create(:users_organisation, user: user3, organisation: organisation, created_at: 2.days.ago)
  end

  let(:orientation_type) { create(:orientation_type, name: "Sociale", casf_category: "social") }
  let!(:orientation) { create(:orientation, organisation: organisation, user: user1, orientation_type:) }

  before do
    setup_agent_session(agent)
    visit organisation_users_path(
      organisation,
      orientation_type_ids: [orientation_type.id],
      follow_up_statuses: ["rdv_seen"],
      search_query: "coucou",
      motif_category_id: motif_category.id,
      referent_ids: [agent.id],
      convocation_date_before: "2025-05-07",
      convocation_date_after: "2025-05-03",
      creation_date_after: "2025-05-05",
      creation_date_before: "2025-05-07",
      last_invitation_date_before: "2025-05-05",
      last_invitation_date_after: "2025-05-03",
      first_invitation_date_before: "2025-05-05",
      first_invitation_date_after: "2025-05-03"
    )
  end

  it "shows a recap of all active filters" do
    expect(page).to have_content("0 dossiers correspondant à votre recherche « coucou »")
    expect(page).to have_content("Orientation : Sociale")
    expect(page).to have_content("Statut : RDV honoré")
    expect(page).to have_content("Suivi par #{agent}")
    expect(page).to have_content("Convoqué entre le : 03/05/2025 et le 07/05/2025")
    expect(page).to have_content("Créé entre le : 05/05/2025 et le 07/05/2025")
    expect(page).to have_content("Dernière invitation envoyée entre le : 03/05/2025 et le 05/05/2025")
    expect(page).to have_content("Première invitation envoyée entre le : 03/05/2025 et le 05/05/2025")
  end
end
