describe "Agents can see créneaux availability before inviting", :js do
  let!(:department) { create(:department) }
  let!(:rdv_solidarites_organisation_id) { 3234 }
  let!(:organisation) do
    create(:organisation, department:, rdv_solidarites_organisation_id:, slug: "org1")
  end
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:motif_category) { create(:motif_category, name: "RSA orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation:, motif_category:)
  end

  let!(:user_list_upload) do
    create(:user_list_upload, agent:, category_configuration:, structure: organisation)
  end

  # the créneaux banner only compares against the number of rows selected for invitation
  let!(:first_row) do
    create(:user_row, user_list_upload:, email: "hernan@crespo.com", selected_for_invitation: true)
  end
  let!(:second_row) do
    create(:user_row, user_list_upload:, email: "christian@vieri.com", selected_for_invitation: true)
  end

  before { setup_agent_session(agent) }

  context "when there are more créneaux than users to invite" do
    let!(:creneaux_snapshot) { create(:creneaux_snapshot, user_list_upload:, number_of_creneaux_available: 50) }

    it "shows an informative banner with a link to the planning" do
      visit select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)

      within(".alert-info") do
        expect(page).to have_content("50 créneaux disponibles")
        expect(page).to have_content("RSA orientation")
        expect(page).to have_link("Consulter le planning")
      end

      expect(page).to have_button("Envoyer les invitations", disabled: false)
    end
  end

  context "when there are fewer créneaux than users to invite" do
    let!(:creneaux_snapshot) { create(:creneaux_snapshot, user_list_upload:, number_of_creneaux_available: 1) }

    it "shows a warning banner but still allows inviting" do
      visit select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)

      within(".alert-warning") do
        expect(page).to have_content("1 créneaux disponibles")
        expect(page).to have_link("Demander plus de créneaux")
      end

      expect(page).to have_button("Envoyer les invitations", disabled: false)
    end
  end

  context "when there are no créneaux available" do
    let!(:creneaux_snapshot) { create(:creneaux_snapshot, user_list_upload:, number_of_creneaux_available: 0) }

    it "shows a danger banner and prevents inviting" do
      visit select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)

      within(".alert-danger") do
        expect(page).to have_content("Aucun créneau disponible")
        expect(page).to have_link("Demander plus de créneaux")
      end

      expect(page).to have_button("Envoyer les invitations", disabled: true)
    end
  end

  context "when the snapshot has not been retrieved yet" do
    it "shows the loading banner with a one-shot refresh" do
      visit select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)

      expect(page).to have_content("Calcul du nombre de créneaux disponibles en cours...")
      expect(page).to have_css("[data-controller='refresh-page-after']")
    end
  end

  context "when the snapshot retrieval has timed out" do
    before { user_list_upload.update_column(:created_at, 3.minutes.ago) }

    it "shows an error banner" do
      visit select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)

      within(".alert-danger") do
        expect(page).to have_content("Le nombre de créneaux disponibles n'a pas pu être récupéré.")
      end
      expect(page).to have_no_content("Calcul du nombre de créneaux disponibles en cours...")
    end
  end

  context "when the category configuration is set with rdv_with_referents" do
    let!(:category_configuration) do
      create(:category_configuration, organisation:, motif_category:, rdv_with_referents: true)
    end
    let!(:creneaux_snapshot) { nil }

    it "does not show any créneaux banner" do
      visit select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)

      expect(page).to have_content("Inviter les usagers à prendre rendez-vous")
      expect(page).to have_no_content("créneaux disponibles")
      expect(page).to have_no_content("Calcul du nombre de créneaux disponibles en cours...")
    end
  end
end
