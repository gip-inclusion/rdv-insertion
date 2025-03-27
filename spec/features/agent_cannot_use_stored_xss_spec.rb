describe "Agent cannot use stored XSS to execute malicious script", :js do
  let!(:department) { create(:department) }
  let!(:user) { create(:user, organisations: [organisation]) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation, department:) }

  before do
    setup_agent_session(agent)
  end

  context "through confirm modal" do
    context "when removing user from organisation" do
      possible_xss_payloads = [
        "<img src=1 onerror=alert(1)>",
        "\">A&lt;img/src/onerror=alert(1)&gt;B",
        "<div onmouseover=\"&#x61;&#x6C;&#x65;&#x72;&#x74;&#x28;&#x31;&#x29;\">hover me</div>",
        "<a href=\"javascript:alert(1)\">click me</a>",
        "<svg><script>alert(1)</script></svg>",
        "<xml><script>alert(1)</script></xml>",
        "<iframe src=\"data:text/html,<script>alert(1)</script>\"></iframe>"
      ]

      possible_xss_payloads.each do |xss_payload|
        context "with payload: #{xss_payload}" do
          before do
            organisation.update_column(:name, "PLIE Valence #{xss_payload}")
          end

          it "does not execute the script in the confirm modal" do
            visit department_user_path(department, user)

            expect(page).to have_content(organisation.name)

            find(".badge", text: organisation.name).find("a").click
            expect(page).to have_content("L'usager sera définitivement supprimé")

            expect(page).to have_content(xss_payload)

            # Add minimal interactions for specific XSS types that require user actions
            if xss_payload.include?("onmouseover")
              begin
                page.execute_script(
                  "document.querySelector('[onmouseover]')?.dispatchEvent(new MouseEvent('mouseover'))"
                )
              rescue StandardError => _e
                # the element might be not found or cannot be interacted with
              end
            end

            if xss_payload.include?("href=\"javascript:alert")
              begin
                page.execute_script("document.querySelector('a[href^=\"javascript:\"]')?.click()")
              rescue StandardError => _e
                # the element might be not found or cannot be interacted with
              end
            end

            # We wait to be sure the injected script would have time to be executed
            sleep 0.5

            # The only check we need: Ensure no alert was triggered (no XSS execution)
            expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
          end
        end
      end
    end

    context "when removing a referent from a user" do
      let!(:referent) { create(:agent, organisations: [organisation], users: [user]) }

      possible_xss_payloads = [
        "<img src=1 onerror=alert(1)>",
        "\">A&lt;img/src/onerror=alert(1)&gt;B",
        "<div onmouseover=\"&#x61;&#x6C;&#x65;&#x72;&#x74;&#x28;&#x31;&#x29;\">hover me</div>",
        "<a href=\"javascript:alert(1)\">click me</a>",
        "<svg><script>alert(1)</script></svg>",
        "<xml><script>alert(1)</script></xml>",
        "<iframe src=\"data:text/html,<script>alert(1)</script>\"></iframe>"
      ]

      possible_xss_payloads.each do |xss_payload|
        context "with payload: #{xss_payload}" do
          before do
            referent.update_column(:first_name, "John #{xss_payload}")
          end

          it "prevents xss" do
            visit organisation_user_path(organisation, user)

            expect(page).to have_css(".badge", text: referent.to_s)

            find(".badge", text: referent.to_s).find("a").click

            within(".modal.show") do
              expect(page).to have_content("John #{xss_payload}")

              # Add minimal interactions for specific XSS types that require user actions
              if xss_payload.include?("onmouseover")
                begin
                  page.execute_script(
                    "document.querySelector('[onmouseover]')?.dispatchEvent(new MouseEvent('mouseover'))"
                  )
                rescue StandardError => _e
                  # the element might be not found or cannot be interacted with
                end
              end

              if xss_payload.include?("href=\"javascript:alert")
                begin
                  page.execute_script("document.querySelector('a[href^=\"javascript:\"]')?.click()")
                rescue StandardError => _e
                  # the element might be not found or cannot be interacted with
                end
              end

              # We wait to be sure the injected script would have time to be executed
              sleep 0.5

              # The only check we need: Ensure no alert was triggered (no XSS execution)
              expect do
                page.driver.browser.switch_to.alert
              end.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
            end
          end
        end
      end
    end

    context "when removing a tag from a user" do
      let!(:tag) { create(:tag, value: "tag", organisations: [organisation]) }

      possible_xss_payloads = [
        "<img src=1 onerror=alert(1)>",
        "\">A&lt;img/src/onerror=alert(1)&gt;B",
        "<div onmouseover=\"&#x61;&#x6C;&#x65;&#x72;&#x74;&#x28;&#x31;&#x29;\">hover me</div>",
        "<a href=\"javascript:alert(1)\">click me</a>",
        "<svg><script>alert(1)</script></svg>",
        "<xml><script>alert(1)</script></xml>",
        "<iframe src=\"data:text/html,<script>alert(1)</script>\"></iframe>"
      ]

      possible_xss_payloads.each do |xss_payload|
        context "with payload: #{xss_payload}" do
          before do
            tag.update_column(:value, xss_payload)
            user.tags << tag
          end

          it "prevents xss" do
            visit organisation_user_path(organisation, user)

            expect(page).to have_content(xss_payload)

            within("div#tags_list") do
              find(".badge", text: xss_payload).find("a").click
            end

            modal = find(".modal.show")
            expect(modal).to have_content(xss_payload)

            # Add minimal interactions for specific XSS types that require user actions
            if xss_payload.include?("onmouseover")
              begin
                page.execute_script(
                  "document.querySelector('[onmouseover]')?.dispatchEvent(new MouseEvent('mouseover'))"
                )
              rescue StandardError => _e
                # the element might be not found or cannot be interacted with
              end
            end

            if xss_payload.include?("href=\"javascript:alert")
              begin
                page.execute_script("document.querySelector('a[href^=\"javascript:\"]')?.click()")
              rescue StandardError => _e
                # the element might be not found or cannot be interacted with
              end
            end

            # We wait to be sure the injected script would have time to be executed
            sleep 0.5

            # The only check we need: Ensure no alert was triggered (no XSS execution)
            expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
          end
        end
      end
    end
  end

  context "through tooltip" do
    context "when checking the archive reason on a user" do
      let!(:archive) { create(:archive, user:, organisation:, created_at: Time.zone.parse("11/03/2025")) }

      possible_xss_payloads = [
        "<img src=1 onerror=alert(1)>",
        "\">A&lt;img/src/onerror=alert(1)&gt;B",
        "<div onmouseover=\"&#x61;&#x6C;&#x65;&#x72;&#x74;&#x28;&#x31;&#x29;\">hover me</div>",
        "<a href=\"javascript:alert(1)\">click me</a>",
        "<svg><script>alert(1)</script></svg>",
        "<xml><script>alert(1)</script></xml>",
        "<iframe src=\"data:text/html,<script>alert(1)</script>\"></iframe>"
      ]

      possible_xss_payloads.each do |xss_payload|
        context "with payload: #{xss_payload}" do
          before do
            archive.update_column(:archiving_reason, xss_payload)
          end

          it "prevents xss" do
            visit organisation_user_path(organisation, user)

            expect(page).to have_content(archive.archiving_reason)

            # Find element with tooltip that includes archiving date
            tooltip_element = find("[data-tooltip-content*='Archivé le 11/03/2025']")
            expect(tooltip_element).to be_present

            # Hover over the element to trigger the tooltip
            tooltip_element.hover

            expect(page).to have_content(xss_payload)

            # Add minimal interactions for specific XSS types that require user actions
            if xss_payload.include?("onmouseover")
              begin
                page.execute_script(
                  "document.querySelector('[onmouseover]')?.dispatchEvent(new MouseEvent('mouseover'))"
                )
              rescue StandardError => _e
                # the element might be not found or cannot be interacted with
              end
            end

            if xss_payload.include?("href=\"javascript:alert")
              begin
                page.execute_script("document.querySelector('a[href^=\"javascript:\"]')?.click()")
              rescue StandardError => _e
                # the element might be not found or cannot be interacted with
              end
            end

            # We wait to be sure the injected script would have time to be executed
            sleep 0.5

            # The only check we need: Ensure no alert was triggered (no XSS execution)
            expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
          end
        end
      end
    end
  end

  context "through js sweet alert" do
    include_context "with new file configuration"

    let!(:category_configuration) { create(:category_configuration, organisation:, file_configuration:) }

    context "when uploading a user list" do
      possible_xss_payloads = [
        "<img src=1 onerror=alert(1)>",
        "\">A&lt;img/src/onerror=alert(1)&gt;B",
        "<div onmouseover=\"&#x61;&#x6C;&#x65;&#x72;&#x74;&#x28;&#x31;&#x29;\">hover me</div>",
        "<a href=\"javascript:alert(1)\">click me</a>",
        "<svg><script>alert(1)</script></svg>",
        "<xml><script>alert(1)</script></xml>",
        "<iframe src=\"data:text/html,<script>alert(1)</script>\"></iframe>"
      ]

      possible_xss_payloads.each do |xss_payload|
        context "with payload: #{xss_payload}" do
          before do
            file_configuration.update_column(:first_name_column, xss_payload)
          end

          it "prevents xss" do
            visit new_organisation_user_list_upload_path(organisation,
                                                         category_configuration_id: category_configuration.id)

            expect(page).to have_content("Choisissez un fichier usagers à charger")
            expect(page).to have_content(organisation.name)

            attach_file(
              "user_list_upload_file",
              Rails.root.join("spec/fixtures/new_fichier_usager_test.xlsx"),
              make_visible: true
            )

            expect(page).to have_content("Le fichier chargé ne correspond pas au format attendu")

            # Add minimal interactions for specific XSS types that require user actions
            if xss_payload.include?("onmouseover")
              begin
                page.execute_script(
                  "document.querySelector('[onmouseover]')?.dispatchEvent(new MouseEvent('mouseover'))"
                )
              rescue StandardError => _e
                # the element might be not found or cannot be interacted with
              end
            end

            if xss_payload.include?("href=\"javascript:alert")
              begin
                page.execute_script("document.querySelector('a[href^=\"javascript:\"]')?.click()")
              rescue StandardError => _e
                # the element might be not found or cannot be interacted with
              end
            end

            # We wait to be sure the injected script would have time to be executed
            sleep 0.5

            # The only check we need: Ensure no alert was triggered (no XSS execution)
            expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
          end
        end
      end
    end

    context "with old upload page" do
      include_context "with file configuration"

      let!(:category_configuration) { create(:category_configuration, organisation:, file_configuration:) }
      let!(:other_organisation) { create(:organisation, department:, agents: [agent]) }

      context "when uploading a user list" do
        possible_xss_payloads = [
          "<img src=1 onerror=alert(1)>",
          "\">A&lt;img/src/onerror=alert(1)&gt;B",
          "<div onmouseover=\"&#x61;&#x6C;&#x65;&#x72;&#x74;&#x28;&#x31;&#x29;\">hover me</div>",
          "<a href=\"javascript:alert(1)\">click me</a>",
          "<svg><script>alert(1)</script></svg>",
          "<xml><script>alert(1)</script></xml>",
          "<iframe src=\"data:text/html,<script>alert(1)</script>\"></iframe>"
        ]

        possible_xss_payloads.each do |xss_payload|
          context "with payload: #{xss_payload}" do
            before do
              organisation.update_column(:name, xss_payload)
            end

            it "prevents xss" do
              visit new_department_upload_path(
                department, category_configuration_id: category_configuration.id
              )

              attach_file(
                "users-list-upload", Rails.root.join("spec/fixtures/fichier_usager_test.xlsx"),
                make_visible: true
              )

              expect(page).to have_button("Créer compte")

              click_button("Créer compte")

              expect(page).to have_content("Veuillez choisir une organisation parmi les suivantes:")

              # Add minimal interactions for specific XSS types that require user actions
              if xss_payload.include?("onmouseover")
                begin
                  page.execute_script(
                    "document.querySelector('[onmouseover]')?.dispatchEvent(new MouseEvent('mouseover'))"
                  )
                rescue StandardError => _e
                  # the element might be not found or cannot be interacted with
                end
              end

              if xss_payload.include?("href=\"javascript:alert")
                begin
                  page.execute_script("document.querySelector('a[href^=\"javascript:\"]')?.click()")
                rescue StandardError => _e
                  # the element might be not found or cannot be interacted with
                end
              end

              # We wait to be sure the injected script would have time to be executed
              sleep 0.5

              # The only check we need: Ensure no alert was triggered (no XSS execution)
              expect do
                page.driver.browser.switch_to.alert
              end.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
            end
          end
        end
      end
    end
  end

  # These tests verify that our XSS detection actually works
  describe "XSS test verification", :js do
    it "detects a regular alert and verifies expectation behavior" do
      visit "/"
      # First verify no alert exists initially
      expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)

      # Execute JavaScript to create an alert
      page.execute_script("alert('XSS Test')")

      # Verify the alert exists and has correct text
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to eq("XSS Test")

      # Verify our main test expectation fails when an alert exists
      expect do
        expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)

      alert.accept
    end

    it "detects XSS from onmouseover events and verifies expectation behavior" do
      visit "/"
      # First verify no alert exists initially
      expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)

      # Create a div with onmouseover XSS and trigger it
      page.execute_script("
        const div = document.createElement('div');
        div.setAttribute('onmouseover', 'alert(\"Mouseover XSS\")');
        div.textContent = 'Hover me';
        document.body.appendChild(div);
        div.dispatchEvent(new MouseEvent('mouseover'));
      ")

      # Verify we can access the alert (would raise NoSuchAlertError if no alert present)
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to eq("Mouseover XSS")

      # Verify our main test expectation fails when an alert exists
      expect do
        expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)

      alert.accept
    end

    it "detects XSS from javascript: URLs and verifies expectation behavior" do
      visit "/"
      # First verify no alert exists initially
      expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)

      # Create a link with javascript: URL and click it
      page.execute_script("
        const link = document.createElement('a');
        link.setAttribute('href', 'javascript:alert(\"Click XSS\")');
        link.textContent = 'Click me';
        document.body.appendChild(link);
        link.click();
      ")

      # Verify we can access the alert (would raise NoSuchAlertError if no alert present)
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to eq("Click XSS")

      # Verify our main test expectation fails when an alert exists
      expect do
        expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)

      alert.accept
    end
  end
end
