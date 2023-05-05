describe "Agents can create applicant through form", js: true do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(
      :organisation,
      department: department,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
      configurations: [configuration]
    )
  end

  let!(:configuration) { create(:configuration) }

  let!(:rdv_solidarites_user_id) { 2323 }
  let!(:rdv_solidarites_organisation_id) { 3234 }

  describe "#create" do
    before do
      setup_agent_session(agent)
      stub_rdv_solidarites_create_user(rdv_solidarites_user_id)
      stub_rdv_solidarites_update_user(rdv_solidarites_user_id)
      stub_rdv_solidarites_get_organisation_user(rdv_solidarites_organisation_id, rdv_solidarites_user_id)
      # somehow the tests fail on CI if we do not put this line, it seems the status are not assigned
      # to the rdv contexts when we create them in Applicants::Save and so there is an error when redirected to
      # show page after creation
      allow_any_instance_of(RdvContext).to receive(:status).and_return("not_invited")
    end

    it "creates an applicant" do
      visit new_organisation_applicant_path(organisation.id)

      page.fill_in "applicant_first_name", with: "Bob"
      page.fill_in "applicant_last_name", with: "Kelso"
      page.fill_in "applicant_email", with: "bob@kelso.com"
      # page.fill_in "applicant_affiliation_number", with: "SOXZAOZA"
      # page.select "demandeur", from: "role"

      click_button("Enregistrer")

      expect(page).to have_content("Modifier")
      expect(page).to have_content("Date de création")
      expect(page).to have_content("Bob")
      expect(page).to have_content("Kelso")
      expect(page).to have_content("bob@kelso.com")
    end

    context "when data is missing" do
      context "when a required attribute is missing" do
        it "returns an error" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_email", with: "bob@kelso.com"

          click_button("Enregistrer")

          expect(page).to have_content("Prénom doit être rempli(e)")
          expect(page).not_to have_content("Modifier")
        end
      end

      context "when there is no identifier for that person" do
        it "returns an error" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"

          click_button("Enregistrer")

          expect(page).to have_content("Il doit y avoir au moins un attribut permettant d'identifier la personne")
          expect(page).not_to have_content("Modifier")
        end
      end
    end

    context "when it finds a matching person in db" do
      context "through nir" do
        let!(:nir) { generate_random_nir }
        let!(:applicant) do
          create(
            :applicant,
            nir: nir, email: nil, created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        end

        it "finds the matching applicant and update with new attributes" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_email", with: "bob@kelso.com"
          page.fill_in "applicant_nir", with: nir

          click_button("Enregistrer")

          expect(page).to have_content("Modifier")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(Applicant.count).to eq(1)
          expect(Applicant.last.email).to eq("bob@kelso.com")
        end
      end

      context "through department_internal_id" do
        let!(:department_internal_id) { "213124" }
        let!(:applicant) do
          create(
            :applicant,
            department_internal_id: department_internal_id, email: nil, created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id,
            organisations: [create(:organisation, department: department)]
          )
        end

        it "finds the matching applicant and update with new attributes" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_email", with: "bob@kelso.com"
          page.fill_in "applicant_department_internal_id", with: department_internal_id

          click_button("Enregistrer")

          expect(page).to have_content("Modifier")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(Applicant.count).to eq(1)
          expect(Applicant.last.email).to eq("bob@kelso.com")
        end
      end

      context "through affiliation_number and role" do
        let!(:affiliation_number) { "SDDZZDA" }
        let!(:role) { "demandeur" }
        let!(:applicant) do
          create(
            :applicant,
            affiliation_number: affiliation_number, role: role, email: nil, created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id,
            organisations: [create(:organisation, department: department)]
          )
        end

        it "finds the matching applicant and update with new attributes" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_email", with: "bob@kelso.com"
          page.fill_in "applicant_affiliation_number", with: affiliation_number
          page.select "demandeur", from: "applicant_role"

          click_button("Enregistrer")

          expect(page).to have_content("Modifier")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(Applicant.count).to eq(1)
          expect(Applicant.last.email).to eq("bob@kelso.com")
        end
      end

      context "through email and first name" do
        let!(:applicant) do
          create(
            :applicant,
            first_name: "bob", email: "bob@kelso.com", phone_number: nil, created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        end

        it "finds the matching applicant and update with new attributes" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_email", with: "bob@kelso.com"
          page.fill_in "applicant_phone_number", with: "0782605941"

          click_button("Enregistrer")

          expect(page).to have_content("Modifier")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(Applicant.count).to eq(1)
          expect(Applicant.last.phone_number).to eq("+33782605941")
        end
      end

      context "through phone_number and first name" do
        let!(:applicant) do
          create(
            :applicant,
            first_name: "bob", phone_number: "+33782605941", created_at: Time.zone.parse("04/05/2022"),
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        end

        it "finds the matching applicant and update with new attributes" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_email", with: "bob@kelso.com"
          page.fill_in "applicant_phone_number", with: "0782605941"

          click_button("Enregistrer")

          expect(page).to have_content("Modifier")
          expect(page).to have_content("Date de création")
          expect(page).to have_content("04/05/2022")
          expect(page).to have_content("bob@kelso.com")
          expect(Applicant.count).to eq(1)
          expect(Applicant.last.phone_number).to eq("+33782605941")
        end
      end
    end

    context "when attributes match but not the nir" do
      let!(:nir) { generate_random_nir }
      let!(:other_nir) { generate_random_nir }

      let!(:applicant) do
        create(
          :applicant,
          first_name: "bob", phone_number: "+33782605941", nir: nir, created_at: Time.zone.parse("04/05/2022"),
          rdv_solidarites_user_id: rdv_solidarites_user_id
        )
      end

      it "cannot create the applicant" do
        visit new_organisation_applicant_path(organisation.id)

        page.fill_in "applicant_first_name", with: "Bob"
        page.fill_in "applicant_last_name", with: "Kelso"
        page.fill_in "applicant_phone_number", with: "0782605941"
        page.fill_in "applicant_nir", with: other_nir

        click_button("Enregistrer")

        expect(page).to have_content("La personne #{applicant.id} correspond mais n'a pas le même NIR")
        expect(page).not_to have_content("Modifier")
        expect(Applicant.count).to eq(1)
      end
    end

    context "when the mail matches but not the first name" do
      let!(:applicant) do
        create(
          :applicant,
          first_name: "bobby", email: "bob@kelso.com", role: nil, created_at: Time.zone.parse("04/05/2022"),
          rdv_solidarites_user_id: rdv_solidarites_user_id
        )
      end

      it "renders a choice between creating and updating" do
        visit new_organisation_applicant_path(organisation.id)

        page.fill_in "applicant_first_name", with: "Bob"
        page.fill_in "applicant_last_name", with: "Kelso"
        page.fill_in "applicant_email", with: "bob@kelso.com"

        click_button("Enregistrer")

        expect(page).to have_content(
          "La personne ci-dessous partage le même email mais est enregistré sous un un prénom différent"
        )
        expect(page).to have_button("C'est la même personne")
        expect(page).to have_button("C'est une autre personne")
      end

      it "can update the existing applicant" do
        visit new_organisation_applicant_path(organisation.id)

        page.fill_in "applicant_first_name", with: "Bob"
        page.fill_in "applicant_last_name", with: "Kelso"
        page.fill_in "applicant_email", with: "bob@kelso.com"

        click_button("Enregistrer")

        expect(page).to have_content(
          "La personne ci-dessous partage le même email mais est enregistré sous un un prénom différent"
        )
        expect(page).to have_button("C'est la même personne")
        expect(page).to have_button("C'est une autre personne")

        click_button("C'est la même personne")

        expect(page).to have_content("Modifier")
        expect(page).to have_content("Date de création")
        expect(page).to have_content("04/05/2022")
        expect(page).to have_content("Bob")
        expect(page).to have_content("bob@kelso.com")
        expect(Applicant.count).to eq(1)
      end

      context "when we choose to create a new applicant" do
        # necessary to not have the same rdv_solidarites_user_id in rdvs response
        before { stub_rdv_solidarites_create_user("some-other-id") }

        it "creates a new applicant" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_email", with: "bob@kelso.com"
          page.fill_in "applicant_department_internal_id", with: "ABBASS"

          click_button("Enregistrer")

          expect(page).to have_content(
            "La personne ci-dessous partage le même email mais est enregistré sous un un prénom différent"
          )
          expect(page).to have_button("C'est la même personne")
          expect(page).to have_button("C'est une autre personne")

          click_button("C'est une autre personne")

          expect(page).to have_content("Modifier")
          expect(page).not_to have_content("04/05/2022")
          expect(page).not_to have_content("bob@kelso.com")
          expect(page).to have_content("Bob")
          expect(Applicant.count).to eq(2)
          expect(applicant.reload.first_name).to eq("bobby")
        end
      end

      context "when we are creating a conjoint" do
        # necessary to not have the same rdv_solidarites_user_id in rdvs response
        before { stub_rdv_solidarites_create_user("some-other-id") }

        it "does not render a choice and creates the applicant" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_email", with: "bob@kelso.com"
          page.select "conjoint", from: "applicant_role"

          click_button("Enregistrer")

          expect(page).to have_content("Modifier")
          expect(page).to have_content("Bob")
          expect(page).to have_content("bob@kelso.com")
          expect(Applicant.count).to eq(2)
        end
      end

      context "when the existing applicant is a conjoint" do
        # necessary to not have the same rdv_solidarites_user_id in rdvs response
        before do
          stub_rdv_solidarites_create_user("some-other-id")
          applicant.update!(role: "conjoint")
        end

        it "does not render a choice and creates the applicant" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_email", with: "bob@kelso.com"
          page.select "conjoint", from: "applicant_role"

          click_button("Enregistrer")

          expect(page).to have_content("Modifier")
          expect(page).to have_content("Bob")
          expect(page).to have_content("bob@kelso.com")
          expect(Applicant.count).to eq(2)
        end
      end
    end

    context "when the phone number matches but not the first name" do
      let!(:applicant) do
        create(
          :applicant,
          first_name: "bobby", phone_number: "0782605941", role: nil, created_at: Time.zone.parse("04/05/2022"),
          rdv_solidarites_user_id: rdv_solidarites_user_id
        )
      end

      it "renders a choice between creating and updating" do
        visit new_organisation_applicant_path(organisation.id)

        page.fill_in "applicant_first_name", with: "Bob"
        page.fill_in "applicant_last_name", with: "Kelso"
        page.fill_in "applicant_phone_number", with: "0782605941"

        click_button("Enregistrer")

        expect(page).to have_content(
          "La personne ci-dessous partage le même téléphone mais est enregistré sous un un prénom différent"
        )
        expect(page).to have_button("C'est la même personne")
        expect(page).to have_button("C'est une autre personne")
      end

      it "can update the existing applicant" do
        visit new_organisation_applicant_path(organisation.id)

        page.fill_in "applicant_first_name", with: "Bob"
        page.fill_in "applicant_last_name", with: "Kelso"
        page.fill_in "applicant_phone_number", with: "0782605941"

        click_button("Enregistrer")

        expect(page).to have_content(
          "La personne ci-dessous partage le même téléphone mais est enregistré sous un un prénom différent"
        )
        expect(page).to have_button("C'est la même personne")
        expect(page).to have_button("C'est une autre personne")

        click_button("C'est la même personne")

        expect(page).to have_content("Modifier")
        expect(page).to have_content("Date de création")
        expect(page).to have_content("04/05/2022")
        expect(page).to have_content("Bob")
        expect(page).to have_content("+33782605941")
        expect(Applicant.count).to eq(1)
      end

      context "when we choose to create a new applicant" do
        # necessary to not have the same rdv_solidarites_user_id in rdvs response
        before { stub_rdv_solidarites_create_user("some-other-id") }

        it "creates a new applicant" do
          visit new_organisation_applicant_path(organisation.id)

          page.fill_in "applicant_first_name", with: "Bob"
          page.fill_in "applicant_last_name", with: "Kelso"
          page.fill_in "applicant_phone_number", with: "0782605941"
          page.fill_in "applicant_department_internal_id", with: "ABBASS"

          click_button("Enregistrer")

          expect(page).to have_content(
            "La personne ci-dessous partage le même téléphone mais est enregistré sous un un prénom différent"
          )
          expect(page).to have_button("C'est la même personne")
          expect(page).to have_button("C'est une autre personne")

          click_button("C'est une autre personne")

          expect(page).to have_content("Modifier")
          expect(page).not_to have_content("04/05/2022")
          expect(page).not_to have_content("+33782605941")
          expect(page).to have_content("Bob")
          expect(Applicant.count).to eq(2)
          expect(applicant.reload.first_name).to eq("bobby")
        end
      end
    end
  end
end
