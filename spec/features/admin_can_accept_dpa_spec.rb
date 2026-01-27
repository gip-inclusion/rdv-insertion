describe "Admins can accept dpa", :js do
  let(:agent) { create(:agent) }
  let(:organisation) { create(:organisation, :without_dpa_agreement, created_at: 2.months.ago) }
  let!(:agent_role) { create(:agent_role, agent:, access_level: "admin", organisation:) }

  before do
    setup_agent_session(agent)
  end

  context "on root page" do
    before do
      visit organisation_users_path(organisation)
    end

    it "requires the agent to accept the DPA" do
      expect(organisation.reload.dpa_agreement).to be_nil
      expect(page).to have_content("Contrat de sous-traitance")
      check("J'accepte le contrat de sous-traitance")
      click_button("Valider")
      expect(page).to have_no_content("Contrat de sous-traitance")

      expect(organisation.reload.dpa_agreement).not_to be_nil
      refresh
      expect(page).to have_no_content("Contrat de sous-traitance")
    end

    context "when attempting to dismiss without accepting" do
      it "stays visible" do
        click_button("Valider")
        find("body").click
        find("body").send_keys(:escape)
        expect(page).to have_content("Contrat de sous-traitance")
      end
    end

    context "when the agent has already accepted the dpa" do
      let(:organisation) { create(:organisation) }

      it "does not require the agent to accept the dpa" do
        expect(page).to have_no_content("Contrat de sous-traitance")
      end
    end

    context "when the organisation has been created too recently" do
      let(:organisation) { create(:organisation, :without_dpa_agreement, created_at: 2.days.ago) }

      it "does not require the agent to accept the dpa" do
        expect(page).to have_no_content("Contrat de sous-traitance")
      end
    end
  end

  context "on a non organisation page with session set to a specific org" do
    before do
      visit organisation_users_path(organisation)
    end

    it "does not require the agent to accept the dpa" do
      visit department_users_path(organisation.department)

      expect(page).to have_content(organisation.department.name)
      expect(page).to have_no_content("Contrat de sous-traitance")

      visit organisation_users_path(organisation)
      expect(page).to have_content("Contrat de sous-traitance")
    end
  end
end
