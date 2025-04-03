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

  let!(:second_department_org) { create(:organisation, department:) }
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
        fill_in "user_row[last_name]", with: "CRESPOGOAL", fill_options: { clear: :backspace }
        find("i.ri-check-line").click
      end

      expect(page).to have_content("CRESPOGOAL")
      expect(hernan_row.reload.last_name).to eq("CRESPOGOAL")

      ## Edit and cancel edit
      table_row = find("tr", text: "CRESPOGOAL")
      last_name_cell = table_row.find("[data-user-row-attribute='last_name']")
      last_name_cell.double_click

      within(table_row) do
        find("i.ri-close-line").click
      end
      expect(page).to have_content("Hernan")

      within(table_row) do
        find("i.ri-arrow-down-s-line").click
      end

      expect(page).to have_content("ID interne")

      within(table_row) do
        find("i.ri-arrow-up-s-line").click
      end

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

      ## Both rows are checked by default
      expect(find("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']")).to be_checked
      expect(find("input[type='checkbox'][data-user-row-id='#{christian_row.id}']")).to be_checked

      expect(hernan_row.reload.selected_for_user_save).to be_truthy
      expect(christian_row.reload.selected_for_user_save).to be_truthy
      expect(page).to have_content("2 usagers sélectionnés")

      # Uncheck all rows
      check_all_button = find("input[type='checkbox'][data-action='click->select-user-rows#toggleAll']")
      expect(check_all_button).to be_checked
      check_all_button.click

      expect(page).to have_content("Aucun usager sélectionné", wait: 5)
      expect(christian_row.reload.selected_for_user_save).to be_falsey
      expect(hernan_row.reload.selected_for_user_save).to be_falsey
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{christian_row.id}']:not(:checked)")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:not(:checked)")

      # All rows selection is preserved after page refresh
      page.refresh
      expect(page).to have_css("input[type='checkbox'][data-action='click->select-user-rows#toggleAll']:not(:checked)")

      # Check all rows
      check_all_button.click

      expect(page).to have_content("2 usagers sélectionnés", wait: 5)
      expect(christian_row.reload.selected_for_user_save).to be_truthy
      expect(hernan_row.reload.selected_for_user_save).to be_truthy
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:checked")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{christian_row.id}']:checked")

      ## Uncheck Christian row
      find("input[type='checkbox'][data-user-row-id='#{christian_row.id}']").uncheck

      expect(page).to have_content("1 usager sélectionné", wait: 5)
      expect(christian_row.reload.selected_for_user_save).to be_falsey
      expect(hernan_row.reload.selected_for_user_save).to be_truthy
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{christian_row.id}']:not(:checked)")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:checked")

      # Save users
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

      expect(find("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']")).to be_checked
      expect(hernan_row.reload.selected_for_invitation).to be_truthy
      expect(page).to have_content("1 usager sélectionné sur 2", wait: 5)

      # Uncheck the checkbox to trigger the invitation
      find("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']").click
      expect(page).to have_content("Aucun usager sélectionné", wait: 5)

      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:not(:checked)")
      expect(hernan_row.reload.selected_for_invitation).to be_falsey

      # Check the checkbox to trigger the invitation
      find("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']").click
      expect(page).to have_content("1 usager sélectionné sur 2", wait: 5)
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:checked")
      expect(hernan_row.reload.selected_for_invitation).to be_truthy

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

    context "with existing matching user" do
      context "matching criteria tests" do
        it "matches an existing user by NIR" do
          user = create(:user, nir: "180333147687266", organisations: [organisation])

          visit new_organisation_user_list_uploads_category_selection_path(organisation)
          choose(motif_category.name)
          click_button("Valider")
          attach_file(
            "user_list_upload_file",
            Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
            make_visible: true
          )
          click_button("Charger les données usagers")

          # Add a wait to ensure user row is matched
          expect(page).to have_content("Hernan", wait: 5)

          hernan_row = UserListUpload::UserRow.find_by(first_name: "Hernan")
          expect(hernan_row.reload.matching_user).to eq(user)
        end

        it "matches an existing user by email and first name" do
          # Create user with matching email and first name
          user = create(
            :user,
            first_name: "Christian",
            email: "christian@vieri.com",
            organisations: [organisation]
          )

          visit new_organisation_user_list_uploads_category_selection_path(organisation)
          choose(motif_category.name)
          click_button("Valider")
          attach_file(
            "user_list_upload_file",
            Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
            make_visible: true
          )
          click_button("Charger les données usagers")

          # Add a wait to ensure user row is matched
          expect(page).to have_content("Christian", wait: 5)

          # Check that the user was matched by email and first name
          christian_row = UserListUpload::UserRow.find_by(first_name: "Christian")
          expect(christian_row.reload.matching_user).to eq(user)
        end

        it "matches an existing user by department_internal_id" do
          # Create user with matching department_internal_id
          user = create(
            :user,
            department_internal_id: "8383",
            organisations: [organisation]
          )

          visit new_organisation_user_list_uploads_category_selection_path(organisation)
          choose(motif_category.name)
          click_button("Valider")
          attach_file(
            "user_list_upload_file",
            Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
            make_visible: true
          )
          click_button("Charger les données usagers")

          # Add a wait to ensure user row is matched
          expect(page).to have_content("Hernan", wait: 5)

          # Check that the user was matched by department_internal_id
          hernan_row = UserListUpload::UserRow.find_by(first_name: "Hernan")
          expect(hernan_row.reload.matching_user).to eq(user)
        end
      end

      context "special status tests" do
        it "highlights different values between file and database" do
          # Create user with a different last name
          create(
            :user,
            first_name: "Hernan",
            last_name: "DIFFERENT",
            nir: "180333147687266",
            organisations: [organisation]
          )

          visit new_organisation_user_list_uploads_category_selection_path(organisation)
          choose(motif_category.name)
          click_button("Valider")
          attach_file(
            "user_list_upload_file",
            Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
            make_visible: true
          )
          click_button("Charger les données usagers")

          expect(page).to have_content("Hernan", wait: 5)

          # Check that the different value is highlighted
          expect(page).to have_css(".alert-success", wait: 5)
          expect(page).to have_css(".ri-checkbox-circle-line", wait: 5)
        end

        it "shows archived status with unchecked row and special background" do
          # Create user that is archived in the organisation
          user = create(:user, nir: "180333147687266", organisations: [organisation])
          create(:archive, user: user, organisation: organisation, archiving_reason: "Déménagement")

          visit new_organisation_user_list_uploads_category_selection_path(organisation)
          choose(motif_category.name)
          click_button("Valider")
          attach_file(
            "user_list_upload_file",
            Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
            make_visible: true
          )
          click_button("Charger les données usagers")

          # Add a wait to ensure user row is matched and rendered
          expect(page).to have_content("Hernan", wait: 5)

          # Check that the row is unchecked and has archived background
          expect(page).to have_css(".background-brown-light", wait: 5)
          expect(page).to have_css("input[type='checkbox']:not(:checked)", wait: 5)

          # Check archiving reason is in the tooltip
          badge = find(".badge.rounded-pill", match: :first, wait: 5)
          expect(badge["data-tooltip-content"]).to include("Dossier archivé")
          expect(badge["data-tooltip-content"]).to include("Déménagement")

          # Check expanded row has archive badge
          find(".ri-arrow-down-s-line", match: :first).click
          expect(page).to have_content("Archivé", wait: 10)
        end

        it "shows closed follow-up status with unchecked row and tooltip" do
          # Create user with a closed follow-up for this motif category
          user = create(:user, nir: "180333147687266", organisations: [organisation])
          create(:follow_up, user: user, motif_category: motif_category, closed_at: Time.zone.now)

          visit new_organisation_user_list_uploads_category_selection_path(organisation)
          choose(motif_category.name)
          click_button("Valider")
          attach_file(
            "user_list_upload_file",
            Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
            make_visible: true
          )
          click_button("Charger les données usagers")

          expect(page).to have_content("Hernan", wait: 5)

          # Check that the row is unchecked
          expect(page).to have_css("input[type='checkbox']:not(:checked)", wait: 5)

          # Check tooltip content using data-tooltip-content attribute
          badge = find(".badge.rounded-pill", match: :first, wait: 5)
          expect(badge["data-tooltip-content"]).to include("Dossier traité")
        end
      end
    end

    context "on user save attempts page" do
      let!(:user) { create(:user, nir: "180333147687266", organisations: [organisation]) }

      context "when the user save is successful" do
        before do
          allow(UserListUpload::SaveUser).to receive(:call).and_return(OpenStruct.new(success?: true, errors: [],
                                                                                      user_id: user.id))
        end

        it "shows the user save attempt is successful" do
          visit new_organisation_user_list_uploads_category_selection_path(organisation)
          choose(motif_category.name)
          click_button("Valider")
          attach_file(
            "user_list_upload_file",
            Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
            make_visible: true
          )
          click_button("Charger les données usagers")

          expect(page).to have_content("Hernan", wait: 5)

          user_list_upload = UserListUpload.last

          # Save users
          perform_enqueued_jobs(only: UserListUpload::SaveUsersJob) do
            click_button("Créer et mettre à jour les dossiers")
            expect(page).to have_current_path(
              user_list_upload_user_save_attempts_path(user_list_upload_id: user_list_upload.id)
            )
          end

          expect(page).to have_content("Mis à jour")
        end
      end

      context "when the user save is not successful" do
        before do
          allow(UserListUpload::SaveUser).to receive(:call).and_return(OpenStruct.new(success?: false,
                                                                                      errors: ["Error"]))
        end

        it "shows the user save attempt is not successful" do
          visit new_organisation_user_list_uploads_category_selection_path(organisation)
          choose(motif_category.name)
          click_button("Valider")
          attach_file(
            "user_list_upload_file",
            Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
            make_visible: true
          )
          click_button("Charger les données usagers")

          # Add a wait to ensure user row is matched and rendered
          expect(page).to have_content("Hernan", wait: 5)

          # Save users
          click_button("Créer et mettre à jour les dossiers")

          user_list_upload = UserListUpload.last

          expect(page).to have_current_path(
            user_list_upload_user_save_attempts_path(user_list_upload_id: user_list_upload.id)
          )
          perform_enqueued_jobs(only: UserListUpload::SaveUsersJob)

          hernan_row = user_list_upload.user_rows.find_by(first_name: "Hernan")

          expect(page).to have_content("Erreur")
          expect(hernan_row.reload).not_to be_user_save_succeeded
          table_row = find("tr", text: "Crespo")
          data_tooltip_content = table_row.find(".badge.rounded-pill")["data-tooltip-content"]
          expect(data_tooltip_content).to include("Erreur")

          last_name_cell = table_row.find("[data-user-row-attribute='last_name']")
          last_name_cell.double_click

          allow(UserListUpload::SaveUser).to receive(:call).and_return(
            OpenStruct.new(success?: true, errors: [], user: OpenStruct.new(id: user.id))
          )

          within(table_row) do
            fill_in "user_row[last_name]", with: "CRESPOGOAL", fill_options: { clear: :backspace }
            find("i.ri-check-line").click
          end

          expect(page).to have_content("CRESPOGOAL")

          perform_enqueued_jobs(only: UserListUpload::SaveUserJob)

          expect(hernan_row.reload).to be_user_save_succeeded
          # Somehow the refresh triggered by the `broadcast_refresh_later` in the `SaveUserJob`
          # is not reflected in test environment, so I have to use a manual fake refresh instead
          page.refresh

          expect(page).to have_content("Mis à jour")
        end
      end
    end
  end

  context "at department level" do
    let!(:agent) { create(:agent, organisations: [organisation, second_department_org]) }
    let!(:second_department_org) { create(:organisation, department: department, slug: "org2") }
    let!(:retrieve_organisation_service_double) { instance_double(UserListUpload::RetrieveOrganisationToAssign) }

    context "when organisation_search_terms are present" do
      it "assigns organisation from file" do
        visit new_department_user_list_uploads_category_selection_path(department)
        choose(motif_category.name)
        click_button("Valider")

        attach_file(
          "user_list_upload_file",
          Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
          make_visible: true
        )
        click_button("Charger les données usagers")

        expect(page).to have_content("Hernan", wait: 5)

        user_list_upload = UserListUpload.last
        hernan_row = user_list_upload.user_rows.find { |row| row.first_name == "Hernan" }

        # Verify organisation was assigned correctly
        expect(hernan_row.reload.organisation_to_assign).to eq(organisation)

        # Save users
        perform_enqueued_jobs(only: UserListUpload::SaveUsersJob) do
          click_button("Créer et mettre à jour les dossiers")
          expect(page).to have_current_path(
            user_list_upload_user_save_attempts_path(user_list_upload_id: user_list_upload.id)
          )

          expect(page).to have_content("Dossier créé", wait: 10)
        end
        expect(hernan_row.user.reload.organisations).to contain_exactly(organisation)
      end
    end

    context "when no organisation_search_terms" do
      before do
        allow(UserListUpload::RetrieveOrganisationToAssign).to receive(:call)
          .and_return(OpenStruct.new(organisation: second_department_org, success?: true))
      end

      it "assigns organisation by retrieving the right one from the sectorisation" do
        visit new_department_user_list_uploads_category_selection_path(department)
        choose(motif_category.name)
        click_button("Valider")

        attach_file(
          "user_list_upload_file",
          Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
          make_visible: true
        )
        click_button("Charger les données usagers")

        expect(page).to have_content("Hernan", wait: 5)

        user_list_upload = UserListUpload.last
        hernan_row = user_list_upload.user_rows.find { |row| row.first_name == "Hernan" }
        # We make sure the organisation_search_terms are not present
        hernan_row.update!(organisation_search_terms: nil)

        # Save users
        perform_enqueued_jobs(only: UserListUpload::SaveUsersJob) do
          click_button("Créer et mettre à jour les dossiers")
          expect(page).to have_current_path(
            user_list_upload_user_save_attempts_path(user_list_upload_id: user_list_upload.id)
          )
        end

        expect(page).to have_content("Dossier créé", wait: 5)
        expect(hernan_row.reload.user.organisations).to contain_exactly(second_department_org)
      end
    end

    context "when organisation retrieval fails" do
      before do
        allow(UserListUpload::RetrieveOrganisationToAssign).to receive(:call)
          .and_return(
            OpenStruct.new(
              organisation: nil, success?: false, errors: ["Impossible de trouver une organisation"]
            )
          )
      end

      it "shows no_organisation_to_assign status when organisation and ask for organisation" do
        visit new_department_user_list_uploads_category_selection_path(department)
        choose(motif_category.name)
        click_button("Valider")

        attach_file(
          "user_list_upload_file",
          Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
          make_visible: true
        )
        click_button("Charger les données usagers")

        expect(page).to have_content("Hernan", wait: 5)

        user_list_upload = UserListUpload.last
        hernan_row = user_list_upload.user_rows.find { |row| row.first_name == "Hernan" }
        # We make sure the organisation_search_terms are not present
        hernan_row.update!(organisation_search_terms: nil)

        # Save users
        perform_enqueued_jobs(only: UserListUpload::SaveUsersJob) do
          click_button("Créer et mettre à jour les dossiers")
          expect(page).to have_current_path(
            user_list_upload_user_save_attempts_path(user_list_upload_id: user_list_upload.id)
          )
        end

        # Verify no organisation was assigned
        expect(hernan_row.reload.organisation_to_assign).to be_nil
        expect(page).to have_content("Assigner une organisation")

        # Test manual organisation assignment
        hernan_row_element = find("tr", text: "Crespo")
        within(hernan_row_element) do
          click_link("Assigner une organisation")
        end

        expect(page).to have_content("Veuillez choisir une organisation pour l'usager")

        # Choose an organisation manually
        select organisation.name, from: "user_list_upload_user_row[assigned_organisation_id]"

        perform_enqueued_jobs(only: UserListUpload::SaveUserJob) do
          click_button("Enregistrer")
          expect(page).to have_content("L'organisation #{organisation.name} a été assignée à l'usager")
        end

        # Somehow the refresh triggered by the `broadcast_refresh_later` in the `SaveUserJob`
        # is not reflected in test environment, so I have to use a manual fake refresh instead
        page.refresh

        expect(page).to have_content("Dossier créé")
        expect(hernan_row.reload.user.organisations).to contain_exactly(organisation)
      end
    end
  end

  context "when selecting rows to invite" do
    let!(:hernan) do
      create(:user, first_name: "Hernan", last_name: "Crespo", email: "hernan@crespo.com", phone_number: "+33698943255")
    end
    let!(:christian) do
      create(:user, first_name: "Christian", last_name: "Vieri", email: "christian@vieri.com", phone_number: nil)
    end
    let!(:user_list_upload) do
      create(
        :user_list_upload,
        agent: agent,
        category_configuration: create(:category_configuration, motif_category: motif_category),
        structure: organisation
      )
    end

    let!(:hernan_row) do
      create(:user_row, user_list_upload:, first_name: "Hernan", last_name: "Crespo",
                        user_save_attempts: [create(:user_save_attempt, success: true, user: hernan)])
    end
    let!(:christian_row) do
      create(:user_row, user_list_upload:, first_name: "Christian", last_name: "Vieri",
                        user_save_attempts: [create(:user_save_attempt, success: true, user: christian)])
    end

    it "can select and unselect rows to invite" do
      visit select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)

      expect(page).to have_content("2 usagers sélectionnés sur 2", wait: 5)

      # expect rows to be checked
      expect(find("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']")).to be_checked
      expect(find("input[type='checkbox'][data-user-row-id='#{christian_row.id}']")).to be_checked

      expect(page).to have_button("Envoyer les invitations")

      expect(hernan_row.selected_for_invitation).to be_truthy
      expect(christian_row.selected_for_invitation).to be_truthy

      #  Uncheck all rows
      check_all_button = find("input[type='checkbox'][data-action='click->select-user-rows#toggleAll']")
      expect(check_all_button).to be_checked
      check_all_button.click

      # expect rows to be unchecked
      expect(page).to have_css("input[type='checkbox'][data-action='click->select-user-rows#toggleAll']:not(:checked)")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:not(:checked)")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{christian_row.id}']:not(:checked)")

      expect(page).to have_content("Aucun usager sélectionné", wait: 5)

      expect(page).to have_button("Envoyer les invitations", disabled: true)

      expect(hernan_row.reload.selected_for_invitation).to be_falsey
      expect(christian_row.reload.selected_for_invitation).to be_falsey

      # checkbox all still unchecked after page refresh
      page.refresh
      expect(page).to have_css("input[type='checkbox'][data-action='click->select-user-rows#toggleAll']:not(:checked)")

      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:not(:checked)")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{christian_row.id}']:not(:checked)")

      # Recheck all rows
      check_all_button.click

      # expect rows to be checked
      expect(page).to have_css("input[type='checkbox'][data-action='click->select-user-rows#toggleAll']:checked")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:checked")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{christian_row.id}']:checked")

      expect(page).to have_content("2 usagers sélectionnés sur 2", wait: 5)

      expect(hernan_row.reload.selected_for_invitation).to be_truthy
      expect(christian_row.reload.selected_for_invitation).to be_truthy

      # Uncheck email format
      expect(page).to have_css("input[type='checkbox'][name='email']:checked")
      expect(page).to have_css("input[type='checkbox'][name='sms']:checked")
      find("input[type='checkbox'][name='email']").click
      expect(page).to have_css("input[type='checkbox'][name='email']:not(:checked)")

      # it unchecks users that can't be invited by email
      expect(page).to have_content("1 usager sélectionné sur 2", wait: 20)

      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:checked")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{christian_row.id}']:not(:checked)")

      expect(christian_row.reload.selected_for_invitation).to be_falsey

      # Uncheck sms format
      expect(page).to have_css("input[type='checkbox'][name='sms']:checked")
      find("input[type='checkbox'][name='sms']").click
      expect(page).to have_css("input[type='checkbox'][name='sms']:not(:checked)")

      # it unchecks users that can't be invited by sms
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']:not(:checked)")
      expect(page).to have_css("input[type='checkbox'][data-user-row-id='#{christian_row.id}']:not(:checked)")

      expect(page).to have_content("Aucun usager sélectionné", wait: 5)

      expect(page).to have_button("Envoyer les invitations", disabled: true)

      expect(hernan_row.reload.selected_for_invitation).to be_falsey
      expect(christian_row.reload.selected_for_invitation).to be_falsey

      # It keeps the formats on page refresh
      page.refresh
      expect(page).to have_css("input[type='checkbox'][name='sms']:not(:checked)")
      expect(page).to have_css("input[type='checkbox'][name='email']:not(:checked)")
    end

    context "when user has already been invited" do
      let!(:follow_up) { create(:follow_up, user: hernan, motif_category: motif_category) }
      let!(:invitation) do
        create(:invitation, follow_up:, user: hernan, format: "email", created_at: Time.zone.parse("24/01/2025"))
      end

      before do
        travel_to(Time.zone.parse("29/01/2025 12:00:00"))
      end

      it "shows the invitation date" do
        visit select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)

        # hernan
        expect(page).to have_content("Invité le 24/01/2025")
        # christian
        expect(page).to have_content("Non invité")

        # both are invitable
        expect(page).to have_content("2 usagers sélectionnés sur 2")
      end

      context "when user has been invited less than 24 hours ago" do
        let!(:invitation) do
          create(:invitation, follow_up: follow_up, user: hernan, format: "email",
                              created_at: Time.zone.parse("29/01/2025 11:00:00"))
        end

        it "shows the invitation date" do
          visit select_rows_user_list_upload_invitation_attempts_path(user_list_upload_id: user_list_upload.id)

          # hernan
          expect(page).to have_content("Invité le 29/01/2025")
          # christian
          expect(page).to have_content("Non invité")

          # Hernan checkbox is disabled
          expect(find("input[type='checkbox'][data-user-row-id='#{hernan_row.id}']")).to be_disabled
          # Christian checkbox is enabled
          expect(find("input[type='checkbox'][data-user-row-id='#{christian_row.id}']")).not_to be_disabled
        end
      end
    end
  end
end
