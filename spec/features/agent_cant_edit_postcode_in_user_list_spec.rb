describe "Post code is not editable in user list upload process", :js do
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
  let!(:rdv_solidarites_user_id) { 2323 }
  let!(:rdv_solidarites_organisation_id) { 3234 }

  before do
    setup_agent_session(agent)
    stub_user_creation(rdv_solidarites_user_id)
  end

  it "prevents post_code from being edited via double click" do
    visit new_organisation_user_list_uploads_category_selection_path(organisation)
    choose(motif_category.name)
    click_button("Valider")

    attach_file(
      "user_list_upload_file",
      Rails.root.join("spec/fixtures/fichier_usager_test_with_save_attempt_errors.xlsx"),
      make_visible: true
    )
    click_button("Charger les données usagers")

    perform_enqueued_jobs(only: UserListUpload::SaveUsersJob) do
      click_button("Créer et mettre à jour les dossiers")
    end

    expect(page).to have_current_path(
      user_list_upload_user_save_attempts_path(user_list_upload_id: UserListUpload.last.id)
    )
    # We count the number of inputs before and after the double click to check if the input is added or not
    email_cell = find("[data-user-row-attribute='email']")
    input_count_before = all("input[type='text']", visible: :all).count
    email_cell.double_click
    # The email input should be added
    expect(all("input[type='text']", visible: :all).count).to eq(input_count_before + 1)
    find("i.ri-close-line").click

    sleep 0.5

    post_code_cell = find("[data-user-row-attribute='post_code']")
    input_count_before = all("input[type='text']", visible: :all).count
    post_code_cell.double_click
    # The input should not be added
    expect(all("input[type='text']", visible: :all).count).to eq(input_count_before)
  end
end
