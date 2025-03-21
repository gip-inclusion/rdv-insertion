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
      xss_payloads = ["<img src=1 onerror=alert(1)>", "\">A&lt;img/src/onerror=alert(1)&gt;B"]

      xss_payloads.each do |xss_payload|
        context "with payload: #{xss_payload}" do
          before do
            organisation.update_column(:name, "PLIE Valence #{xss_payload}")
          end

          it "does not execute the script in the confirm modal" do
            visit department_user_path(department, user)

            expect(page).to have_content(organisation.name)
            expect(page).to have_content(xss_payload)

            find(".badge", text: organisation.name).find("a").click
            expect(page).to have_content("L'usager sera définitivement supprimé")

            # Ensure there are no system alerts
            expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
          end
        end
      end
    end

    context "when removing a referent from a user" do
      let!(:referent) { create(:agent, organisations: [organisation], users: [user]) }

      xss_payloads = ["<img src=1 onerror=alert(1)>", "\">A&lt;img/src/onerror=alert(1)&gt;B"]

      xss_payloads.each do |xss_payload|
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
            end
            expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
          end
        end
      end
    end

    context "when removing a tag from a user" do
      let!(:tag) { create(:tag, value: "tag", organisations: [organisation]) }

      xss_payloads = ["<img src=1 onerror=alert(1)>", "\">A&lt;img/src/onerror=alert(1)&gt;B"]

      xss_payloads.each do |xss_payload|
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

            expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
          end
        end
      end
    end
  end

  context "through tooltip" do
    context "when checking the archive reason on a user" do
      let!(:archive) { create(:archive, user:, organisation:, created_at: Time.zone.parse("11/03/2025")) }

      xss_payloads = ["<img src=1 onerror=alert(1)>", "\">A&lt;img/src/onerror=alert(1)&gt;B"]

      xss_payloads.each do |xss_payload|
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

            # Ensure there are no system alerts (no XSS execution)
            expect do
              page.driver.browser.switch_to.alert
            end.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
          end
        end
      end
    end
  end

  context "through js sweet alert" do
    include_context "with new file configuration"

    let!(:category_configuration) { create(:category_configuration, organisation:, file_configuration:) }

    context "when uploading a user list" do
      xss_payloads = ["<img src=1 onerror=alert(1)>", "\">A&lt;img/src/onerror=alert(1)&gt;B"]

      xss_payloads.each do |xss_payload|
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
        xss_payloads = ["<img src=1 onerror=alert(1)>", "\">A&lt;img/src/onerror=alert(1)&gt;B"]

        xss_payloads.each do |xss_payload|
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

              expect do
                page.driver.browser.switch_to.alert
              end.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
            end
          end
        end
      end
    end
  end
end
