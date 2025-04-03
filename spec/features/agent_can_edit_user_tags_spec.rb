describe "Agents can edit users tags", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) do
    create(:organisation)
  end
  let!(:category_configuration) { create(:category_configuration, organisation: organisation) }
  let!(:user) do
    create(:user, organisations: [organisation])
  end

  let!(:first_tag) { create(:tag, value: "coucou", organisations: [organisation]) }
  let!(:second_tag) { create(:tag, value: "hello", organisations: [organisation]) }

  before do
    setup_agent_session(agent)
  end

  context "the user page" do
    it "allows to edit tags" do
      visit organisation_user_path(organisation, user)

      expect(page).to have_no_content("coucou")
      click_button("Ajouter un tag")

      expect(page).to have_no_content("Tag déjà sélectionné")

      expect(page).to have_content("coucou")
      find("label", text: "coucou").click

      click_button("Ajouter")

      expect(page).to have_content("coucou")
      expect(page).to have_no_content("hello")
      expect(user.reload.tags).to contain_exactly(first_tag)

      click_button("Ajouter un tag")
      expect(page).to have_content("Tag déjà sélectionné")
      expect(page).to have_css(".badge", text: "coucou")

      find("label", text: "hello").click

      click_button("Ajouter")

      expect(page).to have_content("coucou")
      expect(page).to have_content("hello")

      expect(user.reload.tags).to contain_exactly(first_tag, second_tag)

      click_button("Ajouter un tag")

      expect(page).to have_content("Aucun autre tag disponible.")
      click_button("Ok")

      within("#tags_list") do
        find(".badge", text: "coucou").find("a").click
      end
      modal = find(".modal.show")
      modal.click_button("Retirer")

      expect(page).to have_no_content("coucou")
      expect(page).to have_content("hello")
      expect(user.reload.tags).to contain_exactly(second_tag)
    end
  end
end
