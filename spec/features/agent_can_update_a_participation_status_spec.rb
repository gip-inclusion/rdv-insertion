describe "Agents can update a participation status", js: true do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
  end
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: category_orientation) }
  let!(:applicant) do
    create(:applicant, organisations: [organisation])
  end
  let!(:rdv) do
    create(:rdv, organisation: organisation)
  end

  let!(:rdv_context) do
    create(:rdv_context, status: "rdv_seen", applicant: applicant, motif_category: category_orientation)
  end

  let!(:participation) do
    create(:participation, rdv_context: rdv_context, applicant: applicant, rdv: rdv)
  end

  let(:rdvs_user_id) { participation.applicant.rdv_solidarites_user_id }
  let(:rdvs_rdv_id) { participation.rdv.rdv_solidarites_rdv_id }

  before do
    setup_agent_session(agent)
    stub_request(:patch, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/rdvs/#{rdvs_rdv_id}/rdvs_users/#{rdvs_user_id}")
      .to_return(status: 200, body: "{}")
  end

  context "when applicant has rdvs" do
    it "can edit a participation status" do
      visit organisation_applicant_path(organisation, applicant)
      page.execute_script("window.scrollBy(0, 500)")
      expect(page).to have_content("À venir")

      find_by_id("participation_status").click
      find_by_id("participation_status_excused").click

      click_button("Enregistrer")

      expect(page).to have_content("Annulé (excusé)")
    end
  end
end
