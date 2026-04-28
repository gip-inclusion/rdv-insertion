describe "Agent can fill a post-RDV orientation", :js do
  include_context "with all existing categories"

  let(:department) { create(:department) }
  let(:organisation) { create(:organisation, department: department) }
  let(:agent) { create(:agent, organisations: [organisation]) }
  let!(:category_configuration) do
    create(:category_configuration, organisation:, motif_category: category_rsa_orientation)
  end
  let(:user) { create(:user, organisations: [organisation]) }
  let(:motif) { create(:motif, name: "RSA orientation sur site") }
  let(:rdv) { create(:rdv, motif:, organisation: organisation, starts_at: 2.days.ago) }
  let!(:follow_up) do
    create(:follow_up, user:, status: "rdv_pending", motif_category: category_rsa_orientation)
  end
  let(:participation) { create(:participation, follow_up:, user:, rdv:, status: "unknown") }
  let!(:orientation_type) { create(:orientation_type, department: department) }
  let(:rdvs_participation_id) { participation.rdv_solidarites_participation_id }

  before do
    setup_agent_session(agent)
    stub_request(:patch, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/participations/#{rdvs_participation_id}")
      .to_return(status: 200, body: "{}")
  end

  it "shows the orientation form when status is set to seen" do
    visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

    click_button("Statut du RDV à préciser")
    within(".dropdown-menu") { click_button("Rendez-vous honoré") }

    expect(page).to have_css(".modal.show")
    expect(page).to have_content("Renseigner une orientation")

    select "Sociale", from: "Type d'orientation"
    click_button("Enregistrer")

    find("td", text: motif.name).click

    expect(page).to have_content("Orienté en")
    expect(page).to have_content("Sociale")
  end

  context "when an orientation is already filled" do
    let(:participation) { create(:participation, follow_up:, user:, rdv:, status: "revoked") }
    let!(:post_rdv_orientation) { create(:post_rdv_orientation, participation:, orientation_type:) }

    it "does not show the orientation form" do
      visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

      click_button("Annulé (par le service)")
      within(".dropdown-menu") { click_button("Rendez-vous honoré") }

      expect(page).to have_button("Rendez-vous honoré")
      expect(page).to have_no_css(".modal.show")
    end
  end

  context "when an orientation is filled and the status changes away from seen" do
    let(:participation) { create(:participation, follow_up:, user:, rdv:, status: "seen") }
    let!(:post_rdv_orientation) { create(:post_rdv_orientation, participation:, orientation_type:) }

    it "deletes the orientation" do
      visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

      click_button("Rendez-vous honoré")
      within(".dropdown-menu") { click_button("Annulé (par le service)") }

      expect(page).to have_button("Annulé (par le service)")
      expect(PostRdvOrientation.exists?(post_rdv_orientation.id)).to be false
    end
  end
end
