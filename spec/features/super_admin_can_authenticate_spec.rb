describe "Super admins can authenticate", :js do
  let!(:super_admin) { create(:agent, :super_admin) }
  let!(:regular_agent) { create(:agent) }

  before do
    setup_agent_session(super_admin)
  end

  def fill_token_inputs(token)
    first_input = find(".token-input[data-index='0']")
    first_input.click

    # We trigger a paste event with Javascript because filling with Capybara's fill_in method doesn't
    # trigger the stimulus handleInput event and the token is not filled in.
    page.execute_script("
      const input = arguments[0];
      const event = new ClipboardEvent('paste', {
        clipboardData: new DataTransfer()
      });
      event.clipboardData.setData('text/plain', '#{token}');
      input.dispatchEvent(event);
    ", first_input.native)
  end

  context "when super admin accesses super admin area" do
    it "redirects to verification page and completes full authentication flow" do
      visit super_admins_root_path

      expect(page).to have_current_path(new_super_admin_authentication_request_verification_path)
      expect(page).to have_content("Vérification Super Admin")
      expect(page).to have_content("Un code de vérification a été envoyé à l'adresse email #{super_admin.email}")
      expect(page).to have_content("Veuillez entrer le code à 6 chiffres pour continuer")

      expect(page).to have_css(".token-inputs")
      expect(page).to have_css(".token-input", count: 6)
      expect(page).to have_link("Cliquez ici pour renvoyer un nouveau code de vérification")

      # Get the verification token from the database
      authentication_request = super_admin.reload.last_super_admin_authentication_request
      expect(authentication_request).to be_present
      verification_token = authentication_request.token

      fill_token_inputs(verification_token)

      expect(page).to have_content("Connexion Super Admin réussie")
      expect(page).to have_current_path(super_admins_root_path)
    end

    context "when entering invalid verification code" do
      it "shows error message and allows retry" do
        visit super_admins_root_path
        expect(page).to have_current_path(new_super_admin_authentication_request_verification_path)

        fill_token_inputs("111111")

        expect(page).to have_current_path(super_admin_authentication_request_verifications_path)
        expect(page).to have_content("Vérification Super Admin")
        expect(super_admin.reload.last_super_admin_authentication_request.verified_at).to be_nil
      end
    end

    context "when requesting new verification code" do
      it "generates new code and shows success message" do
        visit super_admins_root_path
        expect(page).to have_current_path(new_super_admin_authentication_request_verification_path)

        initial_count = super_admin.super_admin_authentication_requests.count

        # Click regenerate link
        click_link("Cliquez ici pour renvoyer un nouveau code de vérification")

        expect(page).to have_current_path(new_super_admin_authentication_request_verification_path)
        expect(page).to have_content("Vérification Super Admin")
        expect(page).to have_css(".token-inputs")

        expect(super_admin.reload.super_admin_authentication_requests.count).to eq(initial_count + 1)

        # Fill in the new token
        fill_token_inputs(super_admin.reload.last_super_admin_authentication_request.token)

        # Should be redirected to verification page
        expect(page).to have_current_path(super_admins_root_path)
        expect(page).to have_content("Connexion Super Admin réussie")
      end
    end

    context "when verification code expires" do
      it "shows expired error message" do
        visit super_admins_root_path
        expect(page).to have_current_path(new_super_admin_authentication_request_verification_path)

        authentication_request = super_admin.reload.last_super_admin_authentication_request
        verification_token = authentication_request.token

        authentication_request.update!(created_at: 11.minutes.ago)

        fill_token_inputs(verification_token)

        expect(page).to have_current_path(super_admin_authentication_request_verifications_path)
        expect(page).to have_content("Vérification Super Admin")
      end
    end

    context "when exceeding maximum verification attempts" do
      it "invalidates the request and shows error message" do
        visit super_admins_root_path
        expect(page).to have_current_path(new_super_admin_authentication_request_verification_path)

        6.times do
          fill_token_inputs("111111")
          expect(page).to have_current_path(super_admin_authentication_request_verifications_path)
        end

        expect(page).to have_content("Vérification Super Admin")
        expect(super_admin.reload.last_super_admin_authentication_request.invalidated_at).to be_present
      end
    end
  end

  context "when regular agent tries to access super admin area" do
    before do
      setup_agent_session(regular_agent)
    end

    it "denies access with error message" do
      visit super_admins_root_path

      expect(page).to have_current_path(authenticated_root_path)
    end

    it "denies access to verification page" do
      visit new_super_admin_authentication_request_verification_path

      expect(page).to have_current_path(authenticated_root_path)
    end
  end
end
