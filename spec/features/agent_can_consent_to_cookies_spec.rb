describe "Agent can consent to cookies", :js do
  let!(:organisation) { create(:organisation) }
  let!(:agent) { create(:agent, :without_cookies_consent, organisations: [organisation]) }

  before do
    ENV["ENABLE_CRISP"] = "true"
    allow(EnvironmentsHelper).to receive(:production_env?).and_return(true)
  end

  context "when agent is not logged in" do
    it "cannot consent to cookies" do
      visit root_path
      expect(page).to have_no_css("div.fr-consent-banner")
      expect(page).to have_no_content("À propos des cookies sur rdv-insertion.fr")
    end
  end

  context "when agent is logged in" do
    before do
      setup_agent_session(agent)
    end

    it "can accept all cookies" do
      visit organisation_users_path(organisation)
      expect(page).to have_css("div.fr-consent-banner")
      expect(page).to have_content("À propos des cookies sur rdv-insertion.fr")

      expect(page).to have_button("Tout accepter")
      expect(page).to have_button("Tout refuser")
      expect(page).to have_button("Personnaliser")

      # It does not have matomo script tag element
      expect(page).to have_no_css('div[data-controller="matomo-script-tag"]', visible: :hidden)
      # It does not have crisp element
      expect(page).to have_no_css('div[data-controller="crisp"][data-crisp-display-crisp-value="true"]')

      click_button "Tout accepter"
      expect(page).to have_no_css("div.fr-consent-banner")
      expect(page).to have_no_content("À propos des cookies sur rdv-insertion.fr")
      expect(page).to have_current_path(organisation_users_path(organisation))

      expect(agent.reload.cookies_consent).to be_support_accepted
      expect(agent.reload.cookies_consent).to be_tracking_accepted

      visit organisation_users_path(organisation)
      expect(page).to have_no_css("div.fr-consent-banner")
      expect(page).to have_no_content("À propos des cookies sur rdv-insertion.fr")

      ## It has matomo script tag element
      expect(page).to have_css('div[data-controller="matomo-script-tag"]', visible: :hidden)

      ## It has crisp element
      expect(page).to have_css('div[data-controller="crisp"][data-crisp-display-crisp-value="true"]')
    end

    it "can refuse all cookies" do
      visit organisation_users_path(organisation)
      expect(page).to have_css("div.fr-consent-banner")
      expect(page).to have_content("À propos des cookies sur rdv-insertion.fr")

      click_button "Tout refuser"
      expect(page).to have_no_css("div.fr-consent-banner")
      expect(page).to have_no_content("À propos des cookies sur rdv-insertion.fr")
      expect(page).to have_current_path(organisation_users_path(organisation))

      expect(agent.reload.cookies_consent).not_to be_support_accepted
      expect(agent.reload.cookies_consent).not_to be_tracking_accepted

      visit organisation_users_path(organisation)
      expect(page).to have_no_css("div.fr-consent-banner")
      expect(page).to have_no_content("À propos des cookies sur rdv-insertion.fr")

      # It does not have matomo script tag element
      expect(page).to have_no_css('div[data-controller="matomo-script-tag"]', visible: :hidden)
      # It does not have crisp element
      expect(page).to have_no_css('div[data-controller="crisp"][data-crisp-display-crisp-value="true"]')
    end

    it "can customize cookies" do
      visit organisation_users_path(organisation)
      expect(page).to have_css("div.fr-consent-banner")
      expect(page).to have_content("À propos des cookies sur rdv-insertion.fr")

      # We specify the current path to avoid this CI error where the referer is somehow not the current page:
      # https://github.com/gip-inclusion/rdv-insertion/actions/runs/16426240492/job/46417105965
      visit current_path

      click_button "Personnaliser"

      expect(page).to have_css("dialog#consent-modal", wait: 10)
      expect(page).to have_content("Panneau de gestion des cookies")

      # Test case: Accept tracking but refuse support
      within("dialog#consent-modal") do
        find("label[for='tracking-accept']").click
        find("label[for='support-refuse']").click
        click_button "Confirmer mes choix"
      end

      expect(page).to have_no_css("div.fr-consent-banner")
      expect(page).to have_no_content("À propos des cookies sur rdv-insertion.fr")
      expect(page).to have_current_path(organisation_users_path(organisation))

      expect(agent.reload.cookies_consent).to be_tracking_accepted
      expect(agent.reload.cookies_consent).not_to be_support_accepted

      visit organisation_users_path(organisation)
      expect(page).to have_no_css("div.fr-consent-banner")

      # It has matomo script tag element
      expect(page).to have_css('div[data-controller="matomo-script-tag"]', visible: :hidden)
      # It does not have crisp element
      expect(page).to have_no_css('div[data-controller="crisp"][data-crisp-display-crisp-value="true"]')
    end

    it "can customize cookies with opposite choices" do
      visit organisation_users_path(organisation)
      expect(page).to have_css("div.fr-consent-banner")
      expect(page).to have_content("À propos des cookies sur rdv-insertion.fr")

      # We specify the current path to avoid this CI error where the referer is somehow not the current page:
      # https://github.com/gip-inclusion/rdv-insertion/actions/runs/16426240492/job/46417105965
      visit current_path

      click_button "Personnaliser"

      expect(page).to have_css("dialog#consent-modal", wait: 10)
      expect(page).to have_content("Panneau de gestion des cookies")

      # Test case: Refuse tracking but accept support
      within("dialog#consent-modal") do
        find("label[for='tracking-refuse']").click
        find("label[for='support-accept']").click
        click_button "Confirmer mes choix"
      end

      expect(page).to have_no_css("div.fr-consent-banner")
      expect(page).to have_no_content("À propos des cookies sur rdv-insertion.fr")
      expect(page).to have_current_path(organisation_users_path(organisation))

      expect(agent.reload.cookies_consent).not_to be_tracking_accepted
      expect(agent.reload.cookies_consent).to be_support_accepted

      visit organisation_users_path(organisation)
      expect(page).to have_no_css("div.fr-consent-banner")

      # It does not have matomo script tag element
      expect(page).to have_no_css('div[data-controller="matomo-script-tag"]', visible: :hidden)
      # It has crisp element
      expect(page).to have_css('div[data-controller="crisp"][data-crisp-display-crisp-value="true"]')
    end
  end
end
