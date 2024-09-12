describe "Agents can create user through form", :js do
  let!(:agent) { create(:agent, organisations: [organisation, organisation2]) }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(
      :organisation,
      department: department,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
      category_configurations: [category_configuration]
    )
  end

  let!(:organisation2) do
    create(
      :organisation,
      department: department,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id2,
      category_configurations: [category_configuration]
    )
  end

  let!(:category_configuration) { create(:category_configuration) }

  let!(:rdv_solidarites_user_id) { 2323 }
  let!(:rdv_solidarites_organisation_id) { 3234 }
  let!(:rdv_solidarites_organisation_id2) { 3233 }

  describe "#create" do
    before do
      setup_agent_session(agent)
      stub_rdv_solidarites_create_user(rdv_solidarites_user_id)
      stub_sync_with_rdv_solidarites_user(rdv_solidarites_user_id)
      # Somehow the tests fail on CI if we do not put this line, the before_save :set_status callback is not
      # triggered on the follow-ups when we create them (in Users::Save) and so there is an error when redirected
      # to show page after creation
      allow_any_instance_of(FollowUp).to receive(:status).and_return("not_invited")
    end

    it "creates an user" do
      visit new_organisation_user_path(organisation.id)

      page.fill_in "user_first_name", with: "Bob"
      page.fill_in "user_last_name", with: "Kelso"
      page.fill_in "user_email", with: "bob@kelso.com"

      click_button("Enregistrer")

      expect(page).to have_content("Informations")
      expect(page).to have_content("Date de création")
      expect(page).to have_content("Bob")
      expect(page).to have_content("Kelso")
      expect(page).to have_content("bob@kelso.com")

      user = User.last
      expect(user.created_through).to eq("rdv_insertion_user_form")
      expect(user.created_from_structure).to eq(organisation)
    end

    context "from department page" do
      context "no organisation found for this address" do
        it "asks to choose organisation" do
          visit new_department_user_path(organisation.department.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"

          click_button("Enregistrer")

          expect(page).to have_content("Veuillez choisir une organisation")
          find("select.swal2-select").select(organisation2.name)
          click_button("Sélectionner")

          expect(page).to have_content("Informations")
          expect(page).to have_content("Bob")
          expect(page).to have_content(organisation2.name)
        end
      end

      context "an organisation has been found for this address" do
        let!(:address) { "20 avenue de la résistance 26150 Die" }
        let!(:city_code) { "26323" }
        let!(:street_ban_id) { "26444" }
        let!(:rdv_solidarites_id) { 999 }
        let!(:rdv_solidarites_organisation) do
          RdvSolidarites::Organisation.new(id: organisation.rdv_solidarites_organisation_id)
        end

        it "creates user directly" do
          expect(RetrieveAddressGeocodingParams).to receive(:call)
            .with(address:, department_number: organisation.department.number)
            .once
            .and_return(OpenStruct.new(success?: true, geocoding_params: { city_code:, street_ban_id: }))

          expect(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
            .once
            .and_return(OpenStruct.new(success?: true, organisations: [rdv_solidarites_organisation]))

          visit new_department_user_path(organisation.department.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"
          page.fill_in "user_address", with: address

          click_button("Enregistrer")
          expect(page).to have_content("Informations")
          expect(page).to have_content("Bob")
          expect(page).to have_content(organisation.name)
        end
      end
    end

    context "when data is missing" do
      context "when a required attribute is missing" do
        it "returns an error" do
          visit new_organisation_user_path(organisation.id)

          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"

          click_button("Enregistrer")

          expect(page).to have_content("Prénom doit être rempli(e)")
          expect(page).to have_no_content("Informations")
        end
      end

      context "when there is no identifier for that person" do
        it "returns an error" do
          visit new_organisation_user_path(organisation.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"

          click_button("Enregistrer")

          expect(page).to have_content("Il doit y avoir au moins un attribut permettant d'identifier la personne")
          expect(page).to have_no_content("Informations")
        end
      end
    end

    context "when it finds a matching person in db" do
      context "through nir" do
        let!(:nir) { generate_random_nir }
        let!(:user) do
          create(
            :user,
            nir: nir, email: nil, created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        end

        it "finds the matching user and update with new attributes" do
          visit new_organisation_user_path(organisation.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"
          page.fill_in "user_nir", with: nir

          click_button("Enregistrer")

          expect(page).to have_content("Informations")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(User.count).to eq(1)
          expect(User.last.email).to eq("bob@kelso.com")
        end

        context "for creation origin attributes" do
          let!(:user) do
            create(
              :user,
              nir: nir, email: nil, created_at: Time.zone.parse("04/05/2022"),
              rdv_solidarites_user_id: rdv_solidarites_user_id,
              created_through: "rdv_insertion_upload_page", created_from_structure: department
            )
          end

          it "does not update them" do
            visit new_organisation_user_path(organisation.id)

            page.fill_in "user_first_name", with: "Bob"
            page.fill_in "user_last_name", with: "Kelso"
            page.fill_in "user_email", with: "bob@kelso.com"
            page.fill_in "user_nir", with: nir

            click_button("Enregistrer")
            expect(page).to have_content("bob@kelso.com")
            expect(User.count).to eq(1)
            expect(User.last.created_through).to eq("rdv_insertion_upload_page")
            expect(User.last.created_from_structure).to eq(department)
          end
        end
      end

      context "through department_internal_id" do
        let!(:department_internal_id) { "213124" }
        let!(:user) do
          create(
            :user,
            department_internal_id: department_internal_id, email: nil, created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id,
            organisations: [create(:organisation, department: department)]
          )
        end

        it "finds the matching user and update with new attributes" do
          visit new_organisation_user_path(organisation.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"
          page.fill_in "user_department_internal_id", with: department_internal_id

          click_button("Enregistrer")

          expect(page).to have_content("Informations")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(User.count).to eq(1)
          expect(User.last.email).to eq("bob@kelso.com")
        end
      end

      context "through affiliation_number and role" do
        let!(:affiliation_number) { "SDDZZDA" }
        let!(:role) { "demandeur" }
        let!(:user) do
          create(
            :user,
            affiliation_number: affiliation_number, role: role, email: nil, created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id,
            organisations: [create(:organisation, department: department)]
          )
        end

        it "finds the matching user and update with new attributes" do
          visit new_organisation_user_path(organisation.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"
          page.fill_in "user_affiliation_number", with: affiliation_number
          page.select "demandeur", from: "user_role"

          click_button("Enregistrer")

          expect(page).to have_content("Informations")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(User.count).to eq(1)
          expect(User.last.email).to eq("bob@kelso.com")
        end
      end

      context "through email and first name" do
        let!(:user) do
          create(
            :user,
            first_name: "bob", email: "bob@kelso.com", phone_number: nil, created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        end

        it "finds the matching user and update with new attributes" do
          visit new_organisation_user_path(organisation.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"
          page.fill_in "user_phone_number", with: "0782605941"

          click_button("Enregistrer")

          expect(page).to have_content("Informations")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(User.count).to eq(1)
          expect(User.last.phone_number).to eq("+33782605941")
        end
      end

      context "through phone_number and first name" do
        let!(:user) do
          create(
            :user,
            first_name: "bob", phone_number: "+33782605941", created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        end

        it "finds the matching user and update with new attributes" do
          visit new_organisation_user_path(organisation.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"
          page.fill_in "user_phone_number", with: "0782605941"

          click_button("Enregistrer")

          expect(page).to have_content("Informations")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(User.count).to eq(1)
          expect(User.last.phone_number).to eq("+33782605941")
        end
      end
    end

    context "when attributes match but not the nir" do
      let!(:nir) { generate_random_nir }
      let!(:other_nir) { generate_random_nir }

      let!(:user) do
        create(
          :user,
          first_name: "bob", phone_number: "+33782605941", nir: nir, created_at: Time.zone.parse("04/05/2022"),
          rdv_solidarites_user_id: rdv_solidarites_user_id
        )
      end

      it "cannot create the user" do
        visit new_organisation_user_path(organisation.id)

        page.fill_in "user_first_name", with: "Bob"
        page.fill_in "user_last_name", with: "Kelso"
        page.fill_in "user_phone_number", with: "0782605941"
        page.fill_in "user_nir", with: other_nir

        click_button("Enregistrer")

        expect(page).to have_content("Le bénéficiaire #{user.id} a les mêmes attributs mais un nir différent")
        expect(page).to have_no_content("Informations")
        expect(User.count).to eq(1)
      end
    end

    context "when the mail matches but not the first name" do
      let!(:user) do
        create(
          :user,
          first_name: "bobby", email: "bob@kelso.com", role: nil, created_at: Time.zone.parse("04/05/2022"),
          rdv_solidarites_user_id: rdv_solidarites_user_id
        )
      end

      context "when we are creating a conjoint" do
        # necessary to not have the same rdv_solidarites_user_id in rdvs response
        before { stub_rdv_solidarites_create_user("some-other-id") }

        it "does not render a choice and creates the user" do
          visit new_organisation_user_path(organisation.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"
          page.select "conjoint", from: "user_role"

          click_button("Enregistrer")

          expect(page).to have_content("Informations")
          expect(page).to have_content("Bob")
          expect(page).to have_content("bob@kelso.com")
          expect(User.count).to eq(2)
        end
      end

      context "when the existing user is a conjoint" do
        # necessary to not have the same rdv_solidarites_user_id in rdvs response
        before do
          stub_rdv_solidarites_create_user("some-other-id")
          user.update!(role: "conjoint")
        end

        it "does not render a choice and creates the user" do
          visit new_organisation_user_path(organisation.id)

          page.fill_in "user_first_name", with: "Bob"
          page.fill_in "user_last_name", with: "Kelso"
          page.fill_in "user_email", with: "bob@kelso.com"
          page.select "conjoint", from: "user_role"

          click_button("Enregistrer")

          expect(page).to have_content("Informations")
          expect(page).to have_content("Bob")
          expect(page).to have_content("bob@kelso.com")
          expect(User.count).to eq(2)
        end
      end
    end

    context "it shows different attributes depending on organisation type" do
      context "for a conseil departemental" do
        before { organisation.update! organisation_type: "conseil_departemental" }

        it "shows all the attributes" do
          visit new_organisation_user_path(organisation.id)

          expect(page).to have_content("Numéro de sécurité sociale")
          expect(page).to have_content("ID interne au département")
        end
      end

      context "for an siae" do
        before { organisation.update! organisation_type: "siae" }

        it "does not show nir and department_internal_idd" do
          visit new_organisation_user_path(organisation.id)

          expect(page).to have_no_content("Numéro de sécurité sociale")
          expect(page).to have_no_content("ID interne au département")
        end
      end

      context "for delegataire rsa" do
        before { organisation.update! organisation_type: "delegataire_rsa" }

        it "does not show nir and department_internal_idd" do
          visit new_organisation_user_path(organisation.id)

          expect(page).to have_no_content("Numéro de sécurité sociale")
          expect(page).to have_content("ID interne au département")
        end
      end

      context "on department page" do
        before do
          organisation.update! organisation_type: "delegataire_rsa"
          organisation2.update! organisation_type: "conseil_departemental"
        end

        it "shows the lowest informations possible from the organisations" do
          visit new_department_user_path(department.id)

          expect(page).to have_no_content("Numéro de sécurité sociale")
          expect(page).to have_content("ID interne au département")
        end
      end
    end
  end
end
