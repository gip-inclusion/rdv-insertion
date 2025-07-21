describe "Agents can assign referents", :js do
  let!(:organisation) do
    create(:organisation)
  end
  let!(:category_configuration) { create(:category_configuration, organisation: organisation) }
  let!(:user) do
    create(:user, organisations: [organisation])
  end

  let!(:first_agent) { create(:agent, first_name: "Derek", last_name: "Sheperd", organisations: [organisation]) }
  let!(:second_agent) { create(:agent, first_name: "Meredith", last_name: "Grey", organisations: [organisation]) }

  before do
    setup_agent_session(first_agent)
    [first_agent, second_agent].each do |agent|
      stub_rdv_solidarites_assign_referent(user.rdv_solidarites_user_id, agent.rdv_solidarites_agent_id)
    end
  end

  context "the user page" do
    it "allows to assign referents" do
      visit organisation_user_path(organisation, user)

      expect(page).to have_no_content("Derek SHEPERD")
      expect(page).to have_no_content("Meredith GREY")
      click_button("Ajouter un référent")

      expect(page).to have_content("Ajoutez un agent référent")
      expect(page).to have_no_content("Référent déjà assigné")

      expect(page).to have_content("Derek SHEPERD")
      find("label", text: "Derek SHEPERD").click

      click_button("Ajouter")

      expect(page).to have_css(".badge", text: "Derek SHEPERD")
      expect(page).to have_no_content("Meredith GREY")

      expect(user.reload.referents).to contain_exactly(first_agent)

      click_button("Ajouter un référent")
      expect(page).to have_content("Référent déjà assigné")
      expect(page).to have_css(".badge", text: "Derek SHEPERD")

      find("label", text: "Meredith GREY").click

      click_button("Ajouter")

      expect(page).to have_css(".badge", text: "Derek SHEPERD")
      expect(page).to have_css(".badge", text: "Meredith GREY")

      expect(user.reload.referents).to contain_exactly(first_agent, second_agent)

      click_button("Ajouter un référent")

      expect(page).to have_content("Aucun autre référent disponible.")
      click_button("OK")

      find(".badge", text: "Derek SHEPERD").find("a").click
      modal = find(".modal")
      modal.click_button("Retirer")

      expect(page).to have_no_css(".badge", text: "Derek SHEPERD")
      expect(page).to have_css(".badge", text: "Meredith GREY")
      expect(user.reload.referents).to contain_exactly(second_agent)
    end
  end
end
