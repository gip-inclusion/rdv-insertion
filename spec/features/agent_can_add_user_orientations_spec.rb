describe "Agents can add user orientation", :js do
  let!(:agent) { create(:agent) }
  let!(:department) { create(:department, number: "26") }
  let!(:organisation) do
    create(:organisation, name: "CD 26", agents: organisation_agents, department: department)
  end
  let!(:user) do
    create(:user, organisations: [organisation])
  end
  let!(:organisation_agents) do
    [agent, create(:agent, first_name: "Kad", last_name: "Merad"),
     create(:agent, first_name: "Olivier", last_name: "Barroux")]
  end

  let!(:orientation_type_social) do
    create(:orientation_type, name: "Sociale", casf_category: "social", department: nil)
  end
  let!(:orientation_type_pro) do
    create(:orientation_type, name: "Professionnelle", casf_category: "pro", department: nil)
  end
  let!(:orientation_type_socio_pro) do
    create(:orientation_type, name: "Socio-professionnelle", casf_category: "socio_pro", department: nil)
  end

  let!(:other_organisation) do
    create(:organisation, name: "Asso 26", agents: other_organisation_agents, department:)
  end

  let!(:other_organisation_agents) { [create(:agent, first_name: "Jean-Paul", last_name: "Rouve")] }

  before do
    setup_agent_session(agent)
    allow(RdvSolidaritesApi::CreateUserProfiles).to receive(:call).and_return(OpenStruct.new(success?: true))
  end

  it "shows the pacours and enables to add orientations" do
    visit organisation_user_path(organisation_id: organisation.id, id: user.id)
    expect(page).to have_content("Parcours")

    click_link("Parcours")

    expect(page).to have_content("Pas d'orientation renseignée")
    expect(page).to have_button("Ajouter une orientation")

    click_button("Ajouter une orientation")

    page.select orientation_type_social.name, from: "orientation[orientation_type_id]"
    # need to use js for flatpickr input
    page.execute_script("document.querySelector('#orientation_starts_at').value = '2023-07-03'")

    expect(page).to have_css("select#orientation_agent_id[disabled]")

    page.select "CD 26", from: "orientation_organisation_id"
    expect(page).to have_select("orientation_agent_id", with_options: organisation_agents.map(&:to_s))

    page.select "Kad MERAD", from: "orientation_agent_id"

    click_button "Enregistrer"

    expect(page).to have_no_content("Pas d'orientation renseignée")
    expect(page).to have_content("Du 03/07/2023 à aujourd'hui")
    expect(page).to have_content("Sociale")
    expect(page).to have_content("CD 26")
    expect(page).to have_content("Kad MERAD")

    # orientation without agent
    click_button("Ajouter une orientation")

    page.select "Professionnelle", from: "orientation[orientation_type_id]"
    # need to use js for flatpickr input
    page.execute_script("document.querySelector('#orientation_starts_at').value = '2023-10-03'")

    expect(page).to have_css("select#orientation_agent_id[disabled]")

    page.select "Asso 26", from: "orientation_organisation_id"
    expect(page).to have_select("orientation_agent_id", with_options: other_organisation_agents.map(&:to_s))

    click_button "Enregistrer"

    expect(page).to have_content("Cette orientation chevauche")
    click_button "Confirmer"

    expect(page).to have_content("Du 03/07/2023 au 02/10/2023")
    expect(page).to have_content("Sociale")
    expect(page).to have_content("CD 26")
    expect(page).to have_content("Kad MERAD")

    expect(page).to have_content("Du 03/10/2023 à aujourd'hui")
    expect(page).to have_content("Professionnelle")
    expect(page).to have_content("Asso 26")
    expect(page).to have_content("non renseigné")
  end

  it "can update existing orientation and open organisation email notification if needed" do
    orientation = create(:orientation,
                         user: user,
                         starts_at: "2023-07-03",
                         orientation_type: orientation_type_social,
                         organisation: organisation,
                         agent: organisation_agents.first)

    visit organisation_user_path(organisation_id: organisation.id, id: user.id)
    click_link("Parcours")

    within("#orientation_#{orientation.id}") do
      find("i.ri-pencil-fill").click
    end

    page.select orientation_type_pro.name, from: "orientation[orientation_type_id]"
    page.select "Asso 26", from: "orientation_organisation_id"
    page.select "Jean-Paul ROUVE", from: "orientation_agent_id"

    click_button "Enregistrer"
    expect(page).to have_no_content("Informer l’organisation par email")
    click_button "Envoyer"

    expect(page).to have_content("Professionnelle")
    expect(page).to have_content("Asso 26")
    expect(page).to have_content("Jean-Paul ROUVE")
  end

  it "open organisation email notification modal when adding an orientation to another organisation" do
    visit organisation_user_path(organisation_id: organisation.id, id: user.id)

    click_link("Parcours")
    click_button("Ajouter une orientation")

    page.select orientation_type_social.name, from: "orientation[orientation_type_id]"
    page.execute_script("document.querySelector('#orientation_starts_at').value = '2023-07-03'")
    page.select "Asso 26", from: "orientation_organisation_id"
    click_button "Enregistrer"

    expect(page).to have_content("Informer l’organisation par email")
    expect(page).to have_content("Prévenir l’organisation que l’usager a été ajouté à leur liste")

    fill_in "email_custom_content", with: "coucou"

    expect(OrganisationMailer).to receive(:user_added)
      .once
      .with(
        to: other_organisation.email,
        subject: "[RDV-Insertion] Un usager a été ajouté à votre organisation",
        content:
        "L'usager #{user} a été ajouté à votre organisation Asso 26.\nVous pouvez consulter son historique" \
        " d'accompagnement ainsi que les éventuels documents de parcours téléchargés (diagnostic, contrat) sur le" \
        " lien suivant :\n " \
        "http://www.rdv-insertion-test.fake:#{Capybara.current_session.server.port}" \
        "/organisations/#{other_organisation.id}/users/#{user.id}/parcours",
        custom_content: "coucou",
        user_attachments: [],
        reply_to: agent.email
      )
      .and_return(OpenStruct.new(deliver_now: nil))

    click_button "Envoyer"
    expect(page).to have_content("Du 03/07/2023 à aujourd'hui")
    expect(page).to have_content("Asso 26")
  end

  it "open organisation no email warning modal when adding an orientation to another organisation with no email" do
    other_organisation.update(email: nil)
    visit organisation_user_path(organisation_id: organisation.id, id: user.id)

    click_link("Parcours")
    click_button("Ajouter une orientation")

    page.select orientation_type_social.name, from: "orientation[orientation_type_id]"
    page.execute_script("document.querySelector('#orientation_starts_at').value = '2023-07-03'")
    page.select "Asso 26", from: "orientation_organisation_id"
    click_button "Enregistrer"

    expect(page).to have_no_content("Informer l’organisation par email")
    expect(page).to have_content("L'organisation Asso 26 n'a pas d'adresse email renseignée.")
    click_button "J'ai compris"

    expect(page).to have_content("Du 03/07/2023 à aujourd'hui")
    expect(page).to have_content("Asso 26")
  end

  it "does not open email notification modal when user is already in the organisation" do
    user.organisations << other_organisation
    visit organisation_user_path(organisation_id: organisation.id, id: user.id)

    click_link("Parcours")
    click_button("Ajouter une orientation")

    page.select orientation_type_social.name, from: "orientation[orientation_type_id]"
    page.execute_script("document.querySelector('#orientation_starts_at').value = '2023-07-03'")
    page.select "Asso 26", from: "orientation_organisation_id"
    click_button "Enregistrer"

    expect(page).to have_content("Du 03/07/2023 à aujourd'hui")
    expect(page).to have_content("Asso 26")
    expect(page).to have_no_content("Informer l’organisation par email")
    expect(page).to have_no_content("L'organisation Asso 26 n'a pas d'adresse email renseignée.")
  end

  describe "department scoped orientations" do
    let!(:other_department) { create(:department, number: "13") }
    let!(:other_department_agent) { create(:agent) }
    let!(:other_department_organisation) do
      create(:organisation, department: other_department, name: "CD 13", users: [user],
                            agents: [other_department_agent])
    end

    let!(:first_department_orientation) do
      create(:orientation,
             user:,
             starts_at: "20/12/2022",
             ends_at: "03/01/2023",
             orientation_type: orientation_type_social,
             organisation:)
    end

    let!(:second_department_orientation) do
      create(:orientation,
             user:,
             starts_at: "12/01/2023",
             ends_at: "07/02/2023",
             orientation_type: orientation_type_pro,
             organisation: other_department_organisation)
    end

    it "shows only the department scoped orientation" do
      visit department_user_parcours_path(user_id: user.id, department_id: department.id)

      expect(page).to have_content("Du 20/12/2022 au 03/01/2023")
      expect(page).to have_content("CD 26")
      expect(page).to have_content("Sociale")

      expect(page).to have_no_content("Du 12/01/2023 au 07/02/2023")
      expect(page).to have_no_content("CD 13")
      expect(page).to have_no_content("Professionnelle")
    end

    context "for another agent" do
      before { setup_agent_session(other_department_agent) }

      it "shows only the department scoped orientation" do
        visit department_user_parcours_path(user_id: user.id, department_id: other_department.id)

        expect(page).to have_content("Du 12/01/2023 au 07/02/2023")
        expect(page).to have_content("CD 13")
        expect(page).to have_content("Professionnelle")

        expect(page).to have_no_content("Du 20/12/2022 au 03/01/2023")
        expect(page).to have_no_content("CD 26")
        expect(page).to have_no_content("Sociale")
      end
    end
  end
end
