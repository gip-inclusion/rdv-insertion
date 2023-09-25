describe "Agents can edit users tags", js: true do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) do
    create(
      :organisation,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id
    )
  end
  let!(:configuration) { create(:configuration, organisation: organisation) }
  let!(:user) do
    create(
      :user,
      first_name: "Milla", last_name: "Jovovich", rdv_solidarites_user_id: rdv_solidarites_user_id,
      organisations: [organisation]
    )
  end

  let!(:rdv_solidarites_user_id) { 2323 }
  let!(:rdv_solidarites_organisation_id) { 3234 }

  before do
    setup_agent_session(agent)
    stub_rdv_solidarites_update_user(rdv_solidarites_user_id)
    stub_rdv_solidarites_get_organisation_user(rdv_solidarites_organisation_id, rdv_solidarites_user_id)
    organisation.tags << Tag.create!(value: "prout")
  end

  context "the user page" do
    it "allows to edit tags" do
      visit organisation_user_path(organisation, user)
      click_button("Modifier les tags")
      modal = find(".modal")

      modal.find("select option[value=prout]").select_option
      modal.click_button("Ajouter")
      modal.click_button("Fermer")
      expect(user.reload.tags.first.value).to eq("prout")
    end
  end
end