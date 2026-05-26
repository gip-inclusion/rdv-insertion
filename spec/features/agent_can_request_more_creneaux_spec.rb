describe "Agent can request more creneaux", :js do
  let!(:organisation) { create(:organisation) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:motif_category) { create(:motif_category, name: "RSA Orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:user_list_upload) do
    create(:user_list_upload, structure: organisation, category_configuration: category_configuration, agent: agent)
  end
  let!(:recipient_agent) do
    create(:agent, organisations: [organisation], first_name: "Maria", last_name: "Dupuis")
  end

  before { setup_agent_session(agent) }

  it "sends a creneau opening request to the selected agents" do
    visit new_user_list_upload_creneau_opening_request_path(user_list_upload, available_creneaux_count: 26)

    expect(page).to have_content("Demander plus de créneaux")
    expect(page).to have_content("26 créneaux disponibles")
    expect(page).to have_content("RSA Orientation")

    find("label", text: "Maria DUPUIS").click

    click_button "Envoyer la demande"

    expect(page).to have_content("Demande d’ouverture de créneaux envoyées")
    expect(CreneauOpeningRequest.count).to eq(1)
    expect(CreneauOpeningRequest.last.recipient_agent).to eq(recipient_agent)
  end

  it "shows an inline error when no agent is selected" do
    visit new_user_list_upload_creneau_opening_request_path(user_list_upload, available_creneaux_count: 26)

    click_button "Envoyer la demande"

    expect(page).to have_content("Aucun agent destinataire sélectionné")
    expect(CreneauOpeningRequest.count).to eq(0)
  end
end
