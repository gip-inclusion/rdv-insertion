describe "Agents can add or remove applicant from organisations", js: true do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(
      :organisation,
      department: department
      # needed for the organisation applicants page
    )
  end
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: motif_category) }
  let!(:motif_category) { create(:motif_category, name: "Entretien SIAE") }
  let!(:rdv_solidarites_user_id) { 243 }
  let!(:applicant) do
    create(
      :applicant,
      organisations: [organisation],
      rdv_solidarites_user_id: rdv_solidarites_user_id
    )
  end
  let!(:other_org) { create(:organisation, department: department) }
  let!(:other_config) { create(:configuration, organisation: other_org, motif_category: other_motif_category) }
  let!(:other_motif_category) { create(:motif_category, name: "RSA suivi") }

  before do
    setup_agent_session(agent)
  end

  context "from department applicant page" do
    it "can add to an organisation" do
      stub_other_org_user = stub_request(
        :get,
        "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/organisations/#{other_org.rdv_solidarites_organisation_id}/" \
        "users/#{rdv_solidarites_user_id}"
      ).with(
        headers: { "Content-Type" => "application/json" }.merge(session_hash(agent.email))
      ).to_return(status: 404)

      stub_create_user_profile = stub_request(
        :post, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/user_profiles"
      ).with(
        headers: { "Content-Type" => "application/json" }.merge(session_hash(agent.email)),
        body: { user_id: rdv_solidarites_user_id, organisation_id: other_org.rdv_solidarites_organisation_id }.to_json
      ).to_return(
        status: 200,
        body: {
          user_profile: { user_id: rdv_solidarites_user_id, organisation_id: other_org.rdv_solidarites_organisation_id }
        }.to_json
      )

      stub_update_user = stub_request(
        :patch, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/users/#{rdv_solidarites_user_id}"
      ).to_return(
        status: 200,
        body: {
          user: { id: rdv_solidarites_user_id }
        }.to_json
      )

      visit department_applicant_path(department, applicant)

      expect(page).to have_content(organisation.name)
      expect(page).not_to have_content(other_org.name)

      click_link("Ajouter ou retirer une organisation")

      expect(page).to have_content(organisation.name)
      expect(page).to have_content(other_org.name)
      expect(page).to have_select(
        "applicants_organisation[motif_category_id]", options: ["Aucune catégorie", "RSA suivi"]
      )
      select "Aucune catégorie", from: "applicants_organisation[motif_category_id]"

      click_button("+ Ajouter")

      expect(page).to have_content(organisation.name)
      expect(page).to have_content(other_org.name)
      expect(page).to have_content(applicant.last_name)

      expect(stub_other_org_user).to have_been_requested
      expect(stub_create_user_profile).to have_been_requested
      expect(stub_update_user).to have_been_requested
      expect(applicant.reload.organisation_ids).to contain_exactly(organisation.id, other_org.id)
      expect(applicant.reload.motif_categories).not_to include(other_motif_category)
    end

    context "when a motif category is specified" do
      it "adds the applicant in that specific category" do
        stub_other_org_user = stub_request(
          :get,
          "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/organisations/#{other_org.rdv_solidarites_organisation_id}/" \
          "users/#{rdv_solidarites_user_id}"
        ).with(
          headers: { "Content-Type" => "application/json" }.merge(session_hash(agent.email))
        ).to_return(status: 404)

        stub_create_user_profile = stub_request(
          :post, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/user_profiles"
        ).with(
          headers: { "Content-Type" => "application/json" }.merge(session_hash(agent.email)),
          body: { user_id: rdv_solidarites_user_id, organisation_id: other_org.rdv_solidarites_organisation_id }.to_json
        ).to_return(
          status: 200,
          body: {
            user_profile: {
              user_id: rdv_solidarites_user_id, organisation_id: other_org.rdv_solidarites_organisation_id
            }
          }.to_json
        )

        stub_update_user = stub_request(
          :patch, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/users/#{rdv_solidarites_user_id}"
        ).to_return(
          status: 200,
          body: {
            user: { id: rdv_solidarites_user_id }
          }.to_json
        )

        visit department_applicant_path(department, applicant)

        expect(page).to have_content(organisation.name)
        expect(page).not_to have_content(other_org.name)

        click_link("Ajouter ou retirer une organisation")

        expect(page).to have_content(organisation.name)
        expect(page).to have_content(other_org.name)
        expect(page).to have_select(
          "applicants_organisation[motif_category_id]", options: ["Aucune catégorie", "RSA suivi"]
        )

        select "RSA suivi", from: "applicants_organisation[motif_category_id]"

        click_button("+ Ajouter")

        expect(page).to have_content(organisation.name)
        expect(page).to have_content(other_org.name)
        expect(page).to have_content(applicant.last_name)

        expect(stub_other_org_user).to have_been_requested
        expect(stub_create_user_profile).to have_been_requested
        expect(stub_update_user).to have_been_requested
        expect(applicant.reload.organisation_ids).to contain_exactly(organisation.id, other_org.id)
        expect(applicant.reload.motif_categories).to include(other_motif_category)
      end
    end

    it "can remove from org" do
      stub_delete_user_profile = stub_request(
        :delete, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/user_profiles"
      ).with(
        headers: { "Content-Type" => "application/json" }.merge(session_hash(agent.email)),
        query: {
          "user_id" => rdv_solidarites_user_id, "organisation_id" => organisation.rdv_solidarites_organisation_id
        }
      ).to_return(status: 204)

      visit department_applicant_path(department, applicant)
      expect(page).to have_content(organisation.name)
      expect(page).not_to have_content(other_org.name)

      click_link("Ajouter ou retirer une organisation")

      expect(page).to have_content(organisation.name)
      expect(page).to have_content(other_org.name)
      expect(page).to have_button("- Retirer", disabled: false)

      accept_confirm(
        "Cette action va supprimer défintivement la fiche du bénéficiaire, êtes-vous sûr de vouloir la supprimer ?"
      ) do
        click_button("- Retirer")
      end

      expect(page).to have_content("Filtrer")
      expect(page).to have_content("Créer allocataire(s)")

      expect(stub_delete_user_profile).to have_been_requested
      expect(applicant.reload.organisation_ids).to eq([])
      expect(applicant.deleted?).to eq(true)
    end
  end

  context "from organisation page" do
    let!(:applicant) do
      create(
        :applicant,
        organisations: [organisation, other_org],
        rdv_solidarites_user_id: rdv_solidarites_user_id
      )
    end

    it "returns to the department list if the applicant is removed from the org" do
      stub_delete_user_profile = stub_request(
        :delete, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/user_profiles"
      ).with(
        headers: { "Content-Type" => "application/json" }.merge(session_hash(agent.email)),
        query: {
          "user_id" => rdv_solidarites_user_id, "organisation_id" => organisation.rdv_solidarites_organisation_id
        }
      ).to_return(status: 204)

      visit organisation_applicant_path(organisation, applicant)
      expect(page).to have_content(organisation.name)
      expect(page).to have_content(other_org.name)

      click_link("Ajouter ou retirer une organisation")

      expect(page).to have_content(organisation.name)
      expect(page).to have_content(other_org.name)

      expect(page).to have_button("- Retirer", disabled: false)
      expect(page).to have_button("- Retirer", disabled: true)
      click_button("- Retirer")

      expect(page).to have_content("Filtrer")
      expect(page).to have_content("Créer allocataire(s)")

      expect(stub_delete_user_profile).to have_been_requested
      expect(applicant.reload.organisation_ids).to eq([other_org.id])
      expect(applicant.deleted?).to eq(false)
    end
  end
end
