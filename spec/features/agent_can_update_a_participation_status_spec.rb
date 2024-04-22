describe "Agents can update a participation status", :js do
  include_context "with all existing categories"

  let(:department) { create(:department) }
  let(:organisation) { create(:organisation, department: department) }
  let(:agent) { create(:agent, organisations: [organisation]) }
  let!(:category_configuration) do
    create(:category_configuration, organisation:, motif_category: category_rsa_orientation)
  end
  let(:user) do
    create(:user, organisations: [organisation])
  end

  let!(:follow_up) do
    create(:follow_up, user:, status: "rdv_pending", motif_category: category_rsa_orientation)
  end
  let(:rdv) do
    create(:rdv, organisation: organisation)
  end

  let(:participation) do
    create(:participation, follow_up:, user:, rdv:, status: "unknown")
  end

  let(:rdvs_participation_id) { participation.rdv_solidarites_participation_id }

  before do
    setup_agent_session(agent)
    stub_request(:patch, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/participations/#{rdvs_participation_id}")
      .to_return(status: 200, body: "{}")
  end

  context "when user has rdvs" do
    context "rdv is in the past" do
      let(:rdv) do
        create(:rdv, organisation: organisation, starts_at: 2.days.ago)
      end

      it "can edit a participation status" do
        visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)
        page.execute_script("window.scrollBy(0, 500)")
        status_update_button = find_by_id("toggle-rdv-status")
        expect(status_update_button).to have_content("Statut du RDV à préciser")

        status_update_button.click

        expect(page).to have_css("a[data-value=seen]", text: "Rendez-vous honoré")
        expect(page).to have_css("a[data-value=excused]", text: "Annulé (excusé)")
        expect(page).to have_css("a[data-value=revoked]", text: "Annulé (par le service)")
        expect(page).to have_css("a[data-value=noshow]", text: "Absence non excusée")

        expect(page).to have_no_content("Si les notifications sont activées, une alerte sera envoyée à l'usager.")

        find("a[data-value=revoked]").click

        expect(status_update_button).to have_content("Annulé (par le service)")
        expect(participation.reload.status).to eq("revoked")

        status_update_button.click

        expect(page).to have_css("a[data-value=seen]", text: "Rendez-vous honoré")
        expect(page).to have_css("a[data-value=excused]", text: "Annulé (excusé)")
        expect(page).to have_css("a[data-value=noshow]", text: "Absence non excusée")

        expect(page).to have_no_css("a[data-value=revoked]")
        expect(page).to have_no_css("a[data-value=unknown]")

        expect(page).to have_no_content("Si les notifications sont activées, une alerte sera envoyée à l'usager.")
      end
    end

    context "when the rdv is in the future" do
      let(:rdv) do
        create(:rdv, organisation: organisation, starts_at: 2.days.from_now)
      end

      it "can edit a participation status" do
        visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)
        page.execute_script("window.scrollBy(0, 500)")
        status_update_button = find_by_id("toggle-rdv-status")
        expect(status_update_button).to have_content("RDV à venir")

        status_update_button.click

        expect(page).to have_css("a[data-value=excused]", text: "Annulé (excusé)")
        expect(page).to have_css("a[data-value=revoked]", text: "Annulé (par le service)")
        expect(page).to have_text("Si les notifications sont activées, une alerte sera envoyée à l'usager.", count: 2)

        expect(page).to have_no_css("a[data-value=seen]")
        expect(page).to have_no_css("a[data-value=noshow]")
        expect(page).to have_no_content("Rendez-vous honoré")
        expect(page).to have_no_content("Absence non excusée")

        find("a[data-value=revoked]").click

        expect(status_update_button).to have_content("Annulé (par le service)")
        expect(participation.reload.status).to eq("revoked")

        status_update_button.click

        expect(page).to have_css("a[data-value=unknown]", text: "RDV à venir")
        expect(page).to have_css("a[data-value=excused]", text: "Annulé (excusé)")

        expect(page).to have_no_css("a[data-value=revoked]")
        expect(page).to have_no_css("a[data-value=seen]")
        expect(page).to have_no_css("a[data-value=noshow]")
        expect(page).to have_no_content("Rendez-vous honoré")
        expect(page).to have_no_content("Absence non excusée")

        expect(page).to have_text("Si les notifications sont activées, une alerte sera envoyée à l'usager.", count: 1)
      end
    end

    context "when rdv_solidarites_rdv_id is nil" do
      let!(:rdv) do
        create(:rdv, organisation: organisation, rdv_solidarites_rdv_id: nil, starts_at: 1.year.ago)
      end

      it "does not display the toggle button" do
        visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)
        page.execute_script("window.scrollBy(0, 500)")
        expect(page).to have_content("Statut du RDV à préciser")

        expect(page).to have_no_css("#toggle-rdv-status")
      end
    end
  end
end
