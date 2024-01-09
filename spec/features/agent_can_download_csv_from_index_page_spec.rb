describe "Agents can download csv from index page", js: true do
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }
  let!(:organisation) { create(:organisation) }
  let!(:user) do
    create(
      :user,
      organisations: [organisation], email: "someemail@somecompany.com", phone_number: "0607070707"
    )
  end
  let!(:motif_category) { create(:motif_category, short_name: "rsa_follow_up") }
  let!(:motif_category2) { create(:motif_category, short_name: "rsa_insertion_offer") }
  let!(:rdv_solidarites_token) { "123456" }
  let!(:rdv_context) { create(:rdv_context, user: user, motif_category: motif_category, status: "rdv_seen") }
  let!(:rdv_context2) { create(:rdv_context, user: user, motif_category: motif_category2, status: "rdv_seen") }
  let!(:configuration) do
    create(
      :configuration,
      motif_category: motif_category, organisation: organisation, invitation_formats: %w[sms email]
    )
  end
  let!(:configuration2) do
    create(
      :configuration,
      motif_category: motif_category2, organisation: organisation, invitation_formats: %w[sms email]
    )
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }

  before do
    setup_agent_session(agent)
    stub_rdv_solidarites_invitation_requests(user.rdv_solidarites_user_id, rdv_solidarites_token)
    stub_geo_api_request(user.address)
  end

  shared_examples "downloading csv" do
    it "can download participation csv" do
      find_by_id("csvExportButton").click

      click_link("Export de l'historique des rendez-vous")
      expect(downloaded_content).to include("Nature du RDV")
    end

    it "can download users csv" do
      find_by_id("csvExportButton").click

      click_link("Export des usagers")
      expect(downloaded_content).to include("Nature du dernier RDV")
    end
  end

  context "when viewing a specific org" do
    before do
      visit organisation_users_path(organisation, motif_category_id: motif_category.id)
    end

    it_behaves_like "downloading csv"
  end

  context "when viewing the whole department" do
    before do
      visit department_users_path(organisation.department)
    end

    it_behaves_like "downloading csv"
  end
end
