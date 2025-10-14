describe "Agents can filter users with multiselect filters", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation) }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end

  let!(:user1) { create(:user, first_name: "Bertrand") }
  let!(:user2) { create(:user, first_name: "Amanda") }
  let!(:user3) { create(:user, first_name: "Claire") }

  let!(:users_organisation1) { create(:users_organisation, user: user1, organisation: organisation) }
  let!(:users_organisation2) { create(:users_organisation, user: user2, organisation: organisation) }
  let!(:users_organisation3) { create(:users_organisation, user: user3, organisation: organisation) }

  let!(:tag1) { create(:tag, value: "Tag1", organisations: [organisation]) }
  let!(:tag2) { create(:tag, value: "Tag2", organisations: [organisation]) }

  let!(:tag_user1_tag1) { create(:tag_user, tag: tag1, user: user1) }
  let!(:tag_user1_tag2) { create(:tag_user, tag: tag2, user: user1) }
  let!(:tag_user2) { create(:tag_user, tag: tag2, user: user2) }

  let!(:follow_up1) { create(:follow_up, user: user1, motif_category: motif_category, status: "rdv_pending") }
  let!(:follow_up2) { create(:follow_up, user: user2, motif_category: motif_category, status: "rdv_seen") }
  let!(:follow_up3) { create(:follow_up, user: user3, motif_category: motif_category, status: "not_invited") }

  before do
    setup_agent_session(agent)
    visit organisation_users_path(organisation, motif_category_id: motif_category.id)
  end

  context "with tag filters" do
    it "can select and deselect tags" do
      click_button("Tags")
      check("tag_#{tag2.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)

      expect(current_url.scan("tag_ids%5B%5D").count).to eq(1)

      click_button("Tags")
      uncheck("tag_#{tag2.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_content(user3.first_name)

      expect(current_url.scan("tag_ids%5B%5D").count).to eq(0)
    end
  end

  context "with follow_up_status filters" do
    it "can select and deselect statuses" do
      click_button("Statut")
      check("status_rdv_pending")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_no_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)

      expect(current_url.scan("follow_up_statuses%5B%5D").count).to eq(1)

      click_button("Statut")
      uncheck("status_rdv_pending")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_content(user3.first_name)

      expect(current_url.scan("follow_up_statuses%5B%5D").count).to eq(0)
    end
  end
end
