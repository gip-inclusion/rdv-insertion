describe "Matomo URL rewriting with cookie", :js do
  let!(:organisation) { create(:organisation) }
  let!(:user) { create(:user, organisations: [organisation]) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  before do
    allow(EnvironmentsHelper).to receive(:production_env?).and_return(true)
    agent.cookies_consent.update!(tracking_accepted: true)
    setup_agent_session(agent)
  end

  it "sets cookie with masked URL and sends it to Matomo" do
    visit organisation_user_path(organisation, user)

    cookie_value = CGI.unescape(page.driver.browser.manage.cookie_named("matomo_page_url")[:value])
    expect(cookie_value).to eq("/organisations/:organisation_id/users/:id")

    matomo_data = page.evaluate_script("window._mtm")
    custom_url = matomo_data.find { |item| item["customPageUrl"] }&.dig("customPageUrl")
    expect(custom_url).to eq("/organisations/:organisation_id/users/:id")
  end

  it "updates cookie on Turbo navigation" do
    visit organisation_user_path(organisation, user)

    initial_cookie = CGI.unescape(page.driver.browser.manage.cookie_named("matomo_page_url")[:value])
    expect(initial_cookie).to eq("/organisations/:organisation_id/users/:id")

    click_link "Parcours"

    expect(page).to have_content("Historique d'accompagnement")

    new_cookie = CGI.unescape(page.driver.browser.manage.cookie_named("matomo_page_url")[:value])
    expect(new_cookie).to eq("/organisations/:organisation_id/users/:user_id/parcours")

    matomo_data = page.evaluate_script("window._mtm")
    custom_urls = matomo_data.select { |item| item["customPageUrl"] }.map { |item| item["customPageUrl"] }
    expect(custom_urls.last).to eq("/organisations/:organisation_id/users/:user_id/parcours")
  end
end
