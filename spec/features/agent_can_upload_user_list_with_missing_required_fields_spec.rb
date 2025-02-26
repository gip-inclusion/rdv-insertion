describe "Agents upload users with missing required fields", :js do
  include_context "with new file configuration"

  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(
      :organisation,
      department:,
      rdv_solidarites_organisation_id:,
      category_configurations: [category_configuration],
      slug: "org1"
    )
  end

  let!(:category_configuration) { create(:category_configuration, motif_category:, file_configuration:) }
  let!(:motif) { create(:motif, organisation: organisation, motif_category: motif_category) }
  let!(:motif_category) { create(:motif_category) }
  let!(:rdv_solidarites_organisation_id) { 3234 }
  let!(:now) { Time.zone.parse("05/10/2022") }

  before do
    setup_agent_session(agent)
    travel_to now
  end

  it "shows validation errors when title is missing" do
    visit new_organisation_user_list_uploads_category_selection_path(organisation)
    choose(motif_category.name)
    click_button("Valider")

    expect(page).to have_content("Choisissez un fichier usagers à charger")
    attach_file(
      "user_list_upload_file",
      Rails.root.join("spec/fixtures/fichier_usager_sans_titre.xlsx"),
      make_visible: true
    )

    expect(page).to have_content("fichier_usager_sans_titre.xlsx")
    click_button("Charger les données usagers")

    expect(page).to have_content("Usagers avec erreurs 1")

    expect(page).to have_css("[data-user-row-attribute='title'].alert-danger")
    title_cell = find("[data-user-row-attribute='title'].alert-danger")

    expect(title_cell).to have_css("i.ri-alert-line")

    expect(page).to have_css("tr", text: "Virginie")
    error_row = find("tr", text: "Virginie")

    within(error_row) do
      expect(page).to have_css("[data-user-row-attribute='title'] i.ri-alert-line")
    end
  end
end
