describe "Agents can accept cgus", :js do
  let!(:agent) { create(:agent, organisations: [organisation], cgu_accepted_at: nil) }
  let!(:organisation) { create(:organisation) }

  before do
    setup_agent_session(agent)
  end

  context "on root page" do
    before do
      visit organisation_users_path(organisation)
    end

    it "requires the agent to accept the CGU" do
      expect(page).to have_content("Vous devez accepter les conditions")
      check("J'accepte les conditions d'utilisation") 
      click_button("Valider et continuer à utiliser rdv-insertion")
      expect(page).not_to have_content("Vous devez accepter les conditions")

      refresh
      expect(agent.reload.cgu_accepted_at).not_to be_nil
      expect(page).not_to have_content("Vous devez accepter les conditions")
    end

    context "when attempting to dismiss without accepting" do
      it "stays visible" do
        click_button("Valider et continuer à utiliser rdv-insertion")
        find('body').click
        find('body').send_keys(:escape)
        expect(page).to have_content("Vous devez accepter les conditions")
      end
    end

    context "when the agent has already accepted the CGU" do
      let!(:agent) { create(:agent, organisations: [organisation], cgu_accepted_at: Time.zone.now) }

      it "does not require the agent to accept the CGU" do
        expect(page).not_to have_content("Vous devez accepter les conditions")
      end
    end
  end
end
