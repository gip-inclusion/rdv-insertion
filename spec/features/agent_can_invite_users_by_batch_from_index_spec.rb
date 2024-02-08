describe "Agent can invite users by batch from index" do
  let!(:department) { create(:department) }

  let!(:organisation) { create(:organisation, department: department) }
  let!(:motif_category) { create(:motif_category) }
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: motif_category) }
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }

  let!(:agent) { create(:agent, organisations: [organisation]) }

  let!(:user1) { create(:user, last_name: "Dhobb", organisations: [organisation]) }
  let!(:rdv_context1) { create(:rdv_context, user: user1, motif_category: motif_category) }
  let!(:user2) { create(:user, last_name: "Blanc", organisations: [organisation]) }
  let!(:rdv_context2) { create(:rdv_context, user: user2, motif_category: motif_category) }
  let!(:user3) { create(:user, last_name: "Villeneuve", organisations: [organisation]) }
  let!(:rdv_context3) { create(:rdv_context, user: user3, motif_category: motif_category) }
  let!(:invitation3) do
    create(:invitation, rdv_context: rdv_context3, user: user3, department: department,
                        organisations: [organisation], sent_at: Time.zone.now, format: "sms")
  end
  let!(:user4) { create(:user, last_name: "Neuville", organisations: [organisation]) }

  let!(:rdv_solidarites_token1) { "123456" }
  let!(:rdv_solidarites_token2) { "234567" }
  let!(:rdv_solidarites_token3) { "345678" }

  before do
    setup_agent_session(agent)
    stub_rdv_solidarites_invitation_requests(user1.rdv_solidarites_user_id, rdv_solidarites_token1)
    stub_rdv_solidarites_invitation_requests(user2.rdv_solidarites_user_id, rdv_solidarites_token2)
    stub_rdv_solidarites_invitation_requests(user3.rdv_solidarites_user_id, rdv_solidarites_token3)
    stub_geo_api_request(user1.address)
    stub_geo_api_request(user2.address)
    stub_geo_api_request(user3.address)
    stub_request(
      :get,
      /#{Regexp.quote(ENV['RDV_SOLIDARITES_URL'])}\/api\/rdvinsertion\/invitations\/creneau_availability.*/
    ).to_return(status: 200, body: { "creneau_availability" => true }.to_json, headers: {})
    stub_brevo
    rdv_context1.set_status
    rdv_context1.save!
    rdv_context2.set_status
    rdv_context2.save!
    rdv_context3.set_status
    rdv_context3.save!
  end

  context "when agent is at organisation level" do
    it "can export a users selection to a batch_actions page" do
      visit organisation_users_path(organisation, motif_category_id: motif_category.id)

      expect(page).to have_link(
        "Envoyer des invitations en masse",
        href: "#{new_organisation_batch_action_path(organisation)}?action=index&controller=users" \
              "&motif_category_id=#{motif_category.id}&organisation_id=#{organisation.id}"
      )
      expect(page).to have_content(user1.last_name)
      expect(page).to have_content(user2.last_name)
      expect(page).to have_content(user3.last_name)
      expect(page).not_to have_content(user4.last_name)

      select("Non invité", from: "user_status")
      expect(page).not_to have_content(user3.last_name)

      click_link "Envoyer des invitations en masse"

      expect(page).to have_current_path(
        "#{new_organisation_batch_action_path(organisation)}?action=index&controller=users" \
        "&motif_category_id=#{motif_category.id}&organisation_id=#{organisation.id}&status=not_invited"
      )
      expect(page).to have_content(user1.last_name)
      expect(page).to have_content(user2.last_name)
      expect(page).not_to have_content(user3.last_name)
      expect(page).not_to have_content(user4.last_name)
    end

    it "can invite a selection of users" do
      visit "#{new_organisation_batch_action_path(organisation)}?action=index&controller=users" \
            "&motif_category_id=#{motif_category.id}&organisation_id=#{organisation.id}"

      expect(page).to have_content(user1.last_name)
      expect(page).to have_content(user2.last_name)
      expect(page).to have_content(user3.last_name)
      expect(page).not_to have_content(user4.last_name)

      expect(page).to have_button("Actions pour toute la sélection", disabled: false)
      expect(page).to have_content("Inviter par SMS").exactly(2).times
      expect(page).to have_content("Réinviter par SMS").exactly(1).times
      expect(page).to have_content("Inviter par Email").exactly(3).times

      click_button("Réinviter par SMS", wait: 10)
      expect(page).to have_content("Une invitation sms a déjà été envoyée aujourd'hui à cet usager")
      click_button("OK")

      click_button("Actions pour toute la sélection", wait: 10)
      click_button("Invitation par sms", wait: 10)

      expect(page).not_to have_content("Inviter par SMS")
      expect(page).to have_content("Réinviter par SMS").exactly(2).times
      expect(page).to have_content("L'envoi a échoué").exactly(1).times
    end

    it "can return to index page with the same arguments" do
      visit organisation_users_path(organisation, motif_category_id: motif_category.id)
      select("Non invité", from: "user_status")
      click_link "Envoyer des invitations en masse"

      expect(page).to have_button("Retour au suivi")
      click_button("Retour au suivi")

      expect(page).to have_current_path(
        organisation_users_path(organisation, motif_category_id: motif_category.id, status: "not_invited")
      )
    end
  end

  context "when agent is at department level" do
    it "can export a users selection to a batch_actions page" do
      visit department_users_path(department, motif_category_id: motif_category.id)

      expect(page).to have_link(
        "Envoyer des invitations en masse",
        href: "#{new_department_batch_action_path(department)}?action=index&controller=users" \
              "&department_id=#{department.id}&motif_category_id=#{motif_category.id}"
      )
      expect(page).to have_content(user1.last_name)
      expect(page).to have_content(user2.last_name)
      expect(page).to have_content(user3.last_name)
      expect(page).not_to have_content(user4.last_name)

      select("Non invité", from: "user_status")
      expect(page).not_to have_content(user3.last_name)

      click_link "Envoyer des invitations en masse"

      expect(page).to have_current_path(
        "#{new_department_batch_action_path(department)}?action=index&controller=users" \
        "&department_id=#{department.id}&motif_category_id=#{motif_category.id}&status=not_invited"
      )
      expect(page).to have_content(user1.last_name)
      expect(page).to have_content(user2.last_name)
      expect(page).not_to have_content(user3.last_name)
      expect(page).not_to have_content(user4.last_name)
    end

    it "can invite a selection of users" do
      visit "#{new_department_batch_action_path(department)}?action=index&controller=users" \
            "&department_id=#{department.id}&motif_category_id=#{motif_category.id}"

      expect(page).to have_content(user1.last_name)
      expect(page).to have_content(user2.last_name)
      expect(page).to have_content(user3.last_name)
      expect(page).not_to have_content(user4.last_name)

      expect(page).to have_button("Actions pour toute la sélection", disabled: false)
      expect(page).to have_content("Inviter par SMS").exactly(2).times
      expect(page).to have_content("Réinviter par SMS").exactly(1).times
      expect(page).to have_content("Inviter par Email").exactly(3).times

      click_button("Réinviter par SMS", wait: 10)
      expect(page).to have_content("Une invitation sms a déjà été envoyée aujourd'hui à cet usager")
      click_button("OK")

      click_button("Actions pour toute la sélection", wait: 10)
      click_button("Invitation par sms", wait: 10)

      expect(page).not_to have_content("Inviter par SMS")
      expect(page).to have_content("Réinviter par SMS").exactly(2).times
      expect(page).to have_content("L'envoi a échoué").exactly(1).times
    end

    it "can return to index page with the same arguments" do
      visit department_users_path(department, motif_category_id: motif_category.id)
      select("Non invité", from: "user_status")
      click_link "Envoyer des invitations en masse"

      expect(page).to have_button("Retour au suivi")
      click_button("Retour au suivi")

      expect(page).to have_current_path(
        department_users_path(department, motif_category_id: motif_category.id, status: "not_invited")
      )
    end
  end
end
