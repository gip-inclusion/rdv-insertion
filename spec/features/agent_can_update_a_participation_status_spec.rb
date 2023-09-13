describe "Agents can update a participation status", js: true do
  let(:department) { create(:department) }
  let(:organisation) { create(:organisation, department: department) }
  let(:agent) { create(:agent, organisations: [organisation]) }
  let(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation", configurations: [configuration])
  end
  let(:configuration) { create(:configuration, organisation: organisation) }
  let(:applicant) do
    create(:applicant, organisations: [organisation])
  end
  let(:rdv) do
    create(:rdv, organisation: organisation)
  end

  let(:rdv_context) do
    create(:rdv_context, status: "rdv_seen", applicant: applicant, motif_category: category_orientation)
  end

  let(:participation) do
    create(:participation, rdv_context: rdv_context, applicant: applicant, rdv: rdv)
  end

  let(:rdvs_participation_id) { participation.rdv_solidarites_participation_id }

  before do
    setup_agent_session(agent)
    stub_request(:patch, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/rdvs_users/#{rdvs_participation_id}")
      .to_return(status: 200, body: "{}")
  end

  context "when applicant has rdvs" do
    context "rdv is in the past" do
      it "can edit a participation status" do
        visit organisation_applicant_path(organisation, applicant)
        page.execute_script("window.scrollBy(0, 500)")
        expect(page).to have_content("RDV honoré")

        find_by_id("toggle-rdv-status").click
        find("a[data-value=excused]").click

        expect(page).to have_content("RDV annulé à l'initiative de l'allocataire")
      end
    end
  end
end
