describe "Admin can edit organisation tags", :js do
  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation) }
  let!(:category_configuration) { create(:category_configuration, organisation: organisation) }
  let!(:agent_role) { create(:agent_role, organisation: organisation, agent: agent, access_level: "admin") }

  let(:tag_value) { "coucou" }

  before do
    setup_agent_session(agent)
  end

  context "from tags configuration page" do
    it "allows to edit the organisation tags" do
      visit organisation_configuration_tags_path(organisation)
      page.fill_in "tag_value", with: tag_value
      click_button("Créer un tag")

      tag = find(".badge")
      expect(tag).to have_content(tag_value)
      expect(organisation.reload.tags.first.value).to eq(tag_value)
    end

    it "allows to delete the organisation tags" do
      organisation.tags << Tag.create(value: tag_value)

      visit organisation_configuration_tags_path(organisation)
      find("#tag_#{organisation.tags.first.id} a").click
      find_by_id("confirm-button").click
      expect(page).to have_no_selector("#tag_#{organisation.tags.first.id}")

      expect(organisation.reload.tags).to be_empty
    end

    it "displays an error message when tag already exist in this organisation" do
      organisation.tags << Tag.create(value: tag_value)

      visit organisation_configuration_tags_path(organisation)
      page.fill_in "tag_value", with: tag_value
      click_button("Créer un tag")

      expect(page).to have_content("Tag est déjà utilisé")
    end
  end
end
