describe "Matomo URL rewriting", :js do
  let!(:organisation) { create(:organisation) }
  let!(:user) { create(:user, organisations: [organisation]) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  before do
    allow(EnvironmentsHelper).to receive(:production_env?).and_return(true)
    agent.cookies_consent.update!(tracking_accepted: true)
    setup_agent_session(agent)
  end

  it "rewrites organisation and user IDs in the URL" do
    visit organisation_user_path(organisation, user)

    matomo_data = page.evaluate_script("window._mtm")
    custom_url = matomo_data.find { |item| item["customPageUrl"] }&.dig("customPageUrl")

    expect(custom_url).to eq("/organisations/:organisation_id/users/:user_id")
  end

  it "keeps static URLs unchanged" do
    visit stats_path

    matomo_data = page.evaluate_script("window._mtm")
    custom_url = matomo_data.find { |item| item["customPageUrl"] }&.dig("customPageUrl")

    expect(custom_url).to eq("/stats")
  end
end
