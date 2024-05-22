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

  let!(:other_organisation) do
    create(:organisation, name: "Asso 26", agents: other_organisation_agents, department:)
  end

  let!(:other_organisation_agents) { [create(:agent, first_name: "Jean-Paul", last_name: "Rouve")] }

  before { setup_agent_session(agent) }

  context "when the department is not listed with parcours enabled" do
    let!(:department) { create(:department, number: "22") }

    it "does not show the parcours" do
      visit organisation_user_path(organisation_id: organisation.id, id: user.id)
      expect(page).to have_no_content("Parcours")

      visit user_parcours_path(user_id: user.id)
      expect(page).to have_no_content("Ajouter une orientation")
    end
  end

  context "when the department is enabled" do
    it "shows the pacours and enables to add orientations" do
      visit organisation_user_path(organisation_id: organisation.id, id: user.id)
      expect(page).to have_content("Parcours")

      click_link("Parcours")

      expect(page).to have_content("Pas d'orientation renseignée")
      expect(page).to have_button("Ajouter une orientation")

      click_button("Ajouter une orientation")

      page.select "Sociale", from: "orientation_orientation_type"
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

      page.select "Professionnelle", from: "orientation_orientation_type"
      # need to use js for flatpickr input
      page.execute_script("document.querySelector('#orientation_starts_at').value = '2023-10-03'")

      expect(page).to have_css("select#orientation_agent_id[disabled]")

      page.select "Asso 26", from: "orientation_organisation_id"
      expect(page).to have_select("orientation_agent_id", with_options: other_organisation_agents.map(&:to_s))

      click_button "Enregistrer"

      expect(page).to have_content("Du 03/07/2023 au 03/10/2023")
      expect(page).to have_content("Sociale")
      expect(page).to have_content("CD 26")
      expect(page).to have_content("Kad MERAD")

      expect(page).to have_content("Du 03/10/2023 à aujourd'hui")
      expect(page).to have_content("Professionnelle")
      expect(page).to have_content("Asso 26")
      expect(page).to have_content("non renseigné")
    end
  end
end
