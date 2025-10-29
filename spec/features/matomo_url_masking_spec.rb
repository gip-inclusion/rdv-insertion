describe "Matomo URL masking", :js do
  let!(:organisation) { create(:organisation) }
  let!(:user) { create(:user, organisations: [organisation]) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  before do
    ENV["MATOMO_CONTAINER_ID"] = "test123"
    allow(EnvironmentsHelper).to receive(:production_env?).and_return(true)
    agent.cookies_consent.update!(tracking_accepted: true)
    setup_agent_session(agent)
  end

  context "when visiting organisation user page" do
    it "exposes masked URL in Stimulus controller data attribute" do
      visit organisation_user_path(organisation, user)

      expect(page).to have_css(
        'div[data-matomo-script-tag-custom-url-value="/organisations/:organisation_id/users/:id"]',
        visible: :hidden
      )
    end
  end

  context "when visiting follow_ups page" do
    it "masks the URL with follow_ups path" do
      visit organisation_user_follow_ups_path(organisation, user)

      expect(page).to have_css(
        'div[data-matomo-script-tag-custom-url-value="/organisations/:organisation_id/users/:user_id/follow_ups"]',
        visible: :hidden
      )
    end
  end

  context "when visiting department users page" do
    let!(:department) { organisation.department }
    let!(:department_agent) { create(:agent, organisations: [organisation]) }

    before do
      department_agent.cookies_consent.update!(tracking_accepted: true)
      setup_agent_session(department_agent)
    end

    it "masks department and user IDs" do
      visit department_user_path(department, user)

      expect(page).to have_css(
        'div[data-matomo-script-tag-custom-url-value="/departments/:department_id/users/:id"]',
        visible: :hidden
      )
    end
  end

  context "when visiting stats pages" do
    it "keeps stats URLs unchanged" do
      visit stats_path

      expect(page).to have_css(
        'div[data-matomo-script-tag-custom-url-value="/stats"]',
        visible: :hidden
      )
    end
  end
end
