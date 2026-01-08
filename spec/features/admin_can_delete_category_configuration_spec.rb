describe "Agent can delete category configuration", :js do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department, organisation_type: "delegataire_rsa") }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }
  let!(:motif_category) do
    create(
      :motif_category, name: "RSA Orientation", short_name: "rsa_orientation", motif_category_type: "rsa_orientation"
    )
  end
  let!(:file_configuration) { create(:file_configuration) }
  let!(:category_configuration) do
    create(:category_configuration,
           organisation: organisation,
           motif_category: motif_category,
           file_configuration: file_configuration)
  end

  before do
    setup_agent_session(agent)
  end

  it "deletes a category with confirmation" do
    visit organisation_configuration_categories_path(organisation)

    find("[data-action='click->accordion#toggle']").click

    expect(page).to have_content("« RSA Orientation »")

    find("span[data-action='click->confirmation-modal#show']", text: "Supprimer la catégorie").click

    within(".modal", visible: true) do
      expect(page).to have_content("Cette action va supprimer la configuration")
      click_button "Supprimer"
    end

    expect(page).to have_content("Il n'y a pas encore de catégorie configurée")
    expect(CategoryConfiguration.count).to eq(0)
  end
end
