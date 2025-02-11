describe "Agents can upload user list", :js do
  include_context "with new file configuration"

  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(
      :organisation,
      department:,
      rdv_solidarites_organisation_id:,
      # needed for the organisation users page
      category_configurations: [category_configuration],
      slug: "org1"
    )
  end

  let!(:tag) { create(:tag, value: "Cool", organisations: [organisation]) }
  let!(:referent) do
    create(
      :agent,
      organisations: [organisation], email: "marcelo@lippi.com", first_name: "Marcelo", last_name: "Lippi"
    )
  end

  let!(:category_configuration) { create(:category_configuration, motif_category:, file_configuration:) }

  # Needed for the invitations to be sent
  let!(:motif) { create(:motif, organisation: organisation, motif_category: motif_category) }

  let!(:other_org_from_same_department) { create(:organisation, department:) }
  let!(:other_department) { create(:department) }
  let!(:other_org_from_other_department) { create(:organisation, department: other_department) }

  let!(:now) { Time.zone.parse("05/10/2022") }

  let!(:motif_category) { create(:motif_category) }
  let!(:rdv_solidarites_user_id) { 2323 }
  let!(:rdv_solidarites_organisation_id) { 3234 }

  before do
    setup_agent_session(agent)
    stub_user_creation(rdv_solidarites_user_id)
    stub_request(
      :get,
      /#{Regexp.quote(ENV['RDV_SOLIDARITES_URL'])}\/api\/rdvinsertion\/invitations\/creneau_availability.*/
    ).to_return(status: 200, body: { "creneau_availability" => true }.to_json, headers: {})
    allow_any_instance_of(FollowUp).to receive(:status).and_return("invitation_pending")
  end

  context "at organisation level" do
    before { travel_to now }

    it "can upload list of users" do
      ## Category selection
      visit new_organisation_user_list_uploads_category_selection_path(organisation)

      expect(page).to have_content("Sélectionnez la catégorie de suivi sur laquelle importer les usagers")
      expect(page).to have_content("Charger un fichier usagers")
      expect(page).to have_content(motif_category.name)
      expect(page).to have_content("Aucune catégorie de suivi")

      choose(motif_category.name)

      click_button("Valider")

      ## File upload

      expect(page).to have_content("Choisissez un fichier usagers à charger")
      expect(page).to have_content(motif_category.name)
      expect(page).to have_content(organisation.name)

      attach_file(
        "user_list_upload_file",
        Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
        make_visible: true
      )

      expect(page).to have_content("new_fichier_usager_test.xlsx")
      expect(page).to have_content("2 usagers à importer")
      expect(page).to have_content("Changer de fichier")

      click_button("Charger les données usagers")

      ## User list

      expect(page).to have_content("Civilité")
      expect(page).to have_content("monsieur")

      expect(page).to have_content("Prénom")
      expect(page).to have_content("Hernan")
      expect(page).to have_content("Christian")

      expect(page).to have_content("Nom")
      expect(page).to have_content("Crespo")
      expect(page).to have_content("Vieri")

      expect(page).to have_content("Numéro CAF")
      expect(page).to have_content("ISQCJQO")

      expect(page).to have_content("Email")
      expect(page).to have_content("hernan@crespo.com")
      expect(page).to have_content("christian@vieri.com")

      expect(page).to have_content("Statut du dossier")
      expect(page).to have_content("À créer")

      expect(UserListUpload.count).to eq(1)
      expect(UserListUpload::UserRow.count).to eq(2)

      user_list_upload = UserListUpload.last

      expect(page).to have_current_path(user_list_upload_path(user_list_upload))

      expect(user_list_upload.user_rows.count).to eq(2)

      hernan_row = user_list_upload.user_rows.find { |row| row.first_name == "Hernan" }
      christian_row = user_list_upload.user_rows.find { |row| row.first_name == "Christian" }

      expect(hernan_row.first_name).to eq("Hernan")
      expect(hernan_row.last_name).to eq("Crespo")
      expect(hernan_row.matching_user).to be_nil
      expect(hernan_row.tag_values).to eq(["Cool"])

      expect(christian_row.first_name).to eq("Christian")
      expect(christian_row.last_name).to eq("Vieri")
      expect(christian_row.matching_user).to be_nil
      expect(christian_row.tag_values).to eq([])
      expect(christian_row.referent_email).to eq("marcelo@lippi.com")

      ## Test search functionality

      fill_in("search_query", with: "Hernan")

      expect(page).to have_content("Hernan")
      expect(page).to have_content("Crespo")
      expect(page).to have_no_content("Christian")
      expect(page).to have_no_content("Vieri")

      fill_in("search_query", with: "")

      expect(page).to have_content("Christian")
      expect(page).to have_content("Vieri")
      expect(page).to have_content("Hernan")
      expect(page).to have_content("Crespo")

      ## Sort functionnality

      test_ordering_for(
        column_name: "first_name", column_index: 2, default_order: %w[Hernan Christian]
      )
      test_ordering_for(
        column_name: "last_name", column_index: 3, default_order: %w[Crespo Vieri]
      )

      ## Show/Hide details
      table_row = find("tr", text: "Crespo")

      expect(page).to have_no_content("ID interne")
      expect(page).to have_no_content("8383")
      expect(page).to have_no_content("Numéro de sécurité sociale")
      expect(page).to have_no_content("180333147687266")
      expect(page).to have_no_content("Date de naissance")
      expect(page).to have_no_content("Adresse")
      expect(page).to have_no_content("127 RUE DE GRENELLE 75007 PARIS")
      expect(page).to have_no_content("Tags")
      expect(page).to have_no_content("Cool")

      within(table_row) do
        find("i.ri-arrow-down-s-line").click
      end

      expect(page).to have_content("ID interne")
      expect(page).to have_content("8383")
      expect(page).to have_content("Numéro de sécurité sociale")
      expect(page).to have_content("180333147687266")
      expect(page).to have_content("Adresse")
      expect(page).to have_content("127 RUE DE GRENELLE 75007 PARIS")
      expect(page).to have_content("Tags")
      expect(page).to have_content("Cool")

      within(table_row) do
        find("i.ri-arrow-up-s-line").click
      end

      expect(page).to have_no_content("ID interne")
      expect(page).to have_no_content("8383")
      expect(page).to have_no_content("Numéro de sécurité sociale")
      expect(page).to have_no_content("180333147687266")
      expect(page).to have_no_content("Date de naissance")
      expect(page).to have_no_content("Adresse")
      expect(page).to have_no_content("Tags")
      expect(page).to have_no_content("Cool")

      ## Edit attributes
      last_name_cell = table_row.find("[data-user-row-attribute='last_name']")
      last_name_cell.double_click

      within(table_row) do
        fill_in "user_row[last_name]", with: "CRESPOGOAL"
        find("i.ri-check-line").click
      end

      expect(page).to have_content("CRESPOGOAL")
      expect(hernan_row.reload.last_name).to eq("CRESPOGOAL")

      ## Enrich With Cnaf Data
      expect(hernan_row.phone_number).to be_nil
      expect(hernan_row.email).to eq("hernan@crespo.com")

      attach_file(
        "enrich_with_cnaf_data_file_input",
        Rails.root.join("spec/fixtures/fichier_contact_test.csv"),
        make_visible: true
      )

      expect(page).to have_content("+33698943255")
      expect(page).to have_content("hernan.crespo@hotmail.fr")
      expect(hernan_row.reload.cnaf_data["phone_number"]).to eq("+33698943255")
      expect(hernan_row.reload.cnaf_data["email"]).to eq("hernan.crespo@hotmail.fr")

      ## Uncheck Christian row

      find("input[type='checkbox'][value='#{christian_row.id}']").uncheck

      perform_enqueued_jobs(only: UserListUpload::SaveUsersJob) do
        click_button("Créer et mettre à jour les dossiers")
      end

      ## User save attempts
      expect(page).to have_current_path(
        user_list_upload_user_save_attempts_path(user_list_upload_id: user_list_upload.id)
      )

      expect(page).to have_content("CRESPOGOAL")
      expect(page).to have_content("+33698943255")

      expect(page).to have_content("Tous les dossiers ont été créés ou mis à jour.")
      expect(page).to have_content("Dossier créé")

      expect(UserListUpload::UserSaveAttempt.count).to eq(1)

      hernan_save_attempt = UserListUpload::UserSaveAttempt.find_by(user_row_id: hernan_row.id)
      expect(hernan_save_attempt).to be_success

      christian_save_attempt = UserListUpload::UserSaveAttempt.find_by(user_row_id: christian_row.id)
      expect(christian_save_attempt).to be_nil

      expect(User.count).to eq(1)

      hernan_user = User.first
      expect(hernan_user.phone_number).to eq("+33698943255")
      expect(hernan_user.last_name).to eq("CRESPOGOAL")
      expect(hernan_user.nir).to eq("180333147687266")
      expect(hernan_user.affiliation_number).to eq("ISQCJQO")
      expect(hernan_user.department_internal_id).to eq("8383")
      expect(hernan_user.address).to eq("127 RUE DE GRENELLE 75007 PARIS")
      expect(hernan_user.created_from_structure).to eq(organisation)
      expect(hernan_user.created_through).to eq("rdv_insertion_upload_page")
      expect(hernan_user.email).to eq("hernan.crespo@hotmail.fr")
      expect(hernan_user.organisations).to eq([organisation])
      expect(hernan_user.motif_categories).to eq([motif_category])
      expect(hernan_user.tags).to eq([tag])
      expect(hernan_row.reload.user).to eq(hernan_user)

      click_link "Passer aux invitations"

      ## Invitation
      expect(page).to have_current_path(
        select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)
      )
      expect(page).to have_content("Hernan")
      expect(page).to have_content("Non invité")

      perform_enqueued_jobs(only: UserListUpload::InviteUsersJob) do
        click_button("Envoyer les invitations")
      end

      expect(page).to have_current_path(
        user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)
      )

      expect(page).to have_content("Toutes les invitations ont été envoyées.")
      expect(page).to have_content("Invitations envoyées")

      expect(UserListUpload::InvitationAttempt.count).to eq(2)

      expect(UserListUpload::InvitationAttempt.distinct.pluck(:success)).to eq([true])
      expect(UserListUpload::InvitationAttempt.distinct.pluck(:user_row_id)).to eq([hernan_row.id])

      expect(Invitation.count).to eq(2)
      expect(hernan_user.reload.invitations.count).to eq(2)
      expect(hernan_user.invitations.map(&:format)).to contain_exactly("sms", "email")

      click_link "Terminer"

      expect(page).to have_current_path(organisation_users_path(organisation_id: organisation.id))
    end
  end
end
