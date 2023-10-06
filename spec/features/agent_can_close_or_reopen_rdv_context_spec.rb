describe "Agents can close or reopen rdv_context", js: true do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
  end
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: category_orientation) }
  let!(:user) do
    create(:user, organisations: [organisation])
  end
  let!(:rdv_context) do
    create(:rdv_context, user: user, motif_category: category_orientation)
  end

  before do
    setup_agent_session(agent)
  end

  context "from department user page" do
    it "can close and reopen a rdv_context" do
      visit department_user_path(department, user)
      expect(page).to have_content("Clôturer \"RSA orientation\"")

      click_button("Clôturer \"RSA orientation\"")
      expect(page).to have_content("\"RSA orientation\"")

      expect(page).to have_content("Rouvrir \"RSA orientation\"")
      expect(page).to have_content("Dossier traité le")
      expect(rdv_context.reload.status).to eq("closed")
      expect(page).to have_current_path(department_user_path(department, user))

      click_button("Rouvrir \"RSA orientation\"")
      expect(page).to have_content("\"RSA orientation\"")

      expect(page).to have_content("Clôturer \"RSA orientation\"")
      expect(page).to have_content("Non invité")
      expect(rdv_context.reload.status).to eq("not_invited")
      expect(rdv_context.reload.closed_at).to eq(nil)
      expect(page).to have_current_path(department_user_path(department, user))
    end
  end

  context "from organisation user page" do
    it "can close and reopen rdv_context" do
      visit organisation_user_path(organisation, user)
      expect(page).to have_content("Clôturer \"RSA orientation\"")

      click_button("Clôturer \"RSA orientation\"")
      expect(page).to have_content("\"RSA orientation\"")

      expect(page).to have_content("Rouvrir \"RSA orientation\"")
      expect(page).to have_content("Dossier traité le")
      expect(rdv_context.reload.status).to eq("closed")
      expect(page).to have_current_path(organisation_user_path(organisation, user))

      click_button("Rouvrir \"RSA orientation\"")
      expect(page).to have_content("\"RSA orientation\"")

      expect(page).to have_content("Clôturer \"RSA orientation\"")
      expect(page).to have_content("Non invité")
      expect(rdv_context.reload.closed_at).to eq(nil)
      expect(page).to have_current_path(organisation_user_path(organisation, user))
    end
  end
end
