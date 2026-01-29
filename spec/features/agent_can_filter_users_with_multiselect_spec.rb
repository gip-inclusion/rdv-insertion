describe "Agents can filter users with multiselect filters", :js do
  let!(:department) { create(:department) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation, department: department) }
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

  let!(:referent1) { create(:agent, first_name: "Jean", last_name: "Dupont", organisations: [organisation]) }
  let!(:referent2) { create(:agent, first_name: "Marie", last_name: "Martin", organisations: [organisation]) }

  let!(:referent_assignation1) { create(:referent_assignation, user: user1, agent: referent1) }
  let!(:referent_assignation2) { create(:referent_assignation, user: user2, agent: referent2) }

  let!(:orientation_type1) do
    create(:orientation_type, name: "Sociale", casf_category: "social", department: department)
  end
  let!(:orientation_type2) do
    create(:orientation_type, name: "Professionnelle", casf_category: "pro", department: department)
  end

  let!(:orientation1) do
    create(:orientation, organisation: organisation, user: user1, orientation_type: orientation_type1)
  end
  let!(:orientation2) do
    create(:orientation, organisation: organisation, user: user2, orientation_type: orientation_type2)
  end

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

    it "can remove tag filter by clicking on the cross" do
      click_button("Tags")
      check("tag_#{tag2.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)

      within(".active-filter-badge", text: tag2.value) do
        find("i.ri-close-line").click
      end

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

    it "can remove status filter by clicking on the cross" do
      click_button("Statut")
      check("status_rdv_pending")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_no_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)

      within(".active-filter-badge", text: "RDV à venir") do
        find("i.ri-close-line").click
      end

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_content(user3.first_name)

      expect(current_url.scan("follow_up_statuses%5B%5D").count).to eq(0)
    end
  end

  context "with referent filters" do
    it "can select and deselect referents" do
      click_button("Référent")
      check("referent_#{referent1.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_no_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)

      expect(current_url.scan("referent_ids%5B%5D").count).to eq(1)

      click_button("Référent")
      check("referent_#{referent2.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)

      expect(current_url.scan("referent_ids%5B%5D").count).to eq(2)

      click_button("Référent")
      uncheck("referent_#{referent1.id}")
      uncheck("referent_#{referent2.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_content(user3.first_name)

      expect(current_url.scan("referent_ids%5B%5D").count).to eq(0)
    end

    it "can remove referent filter by clicking on the cross" do
      click_button("Référent")
      check("referent_#{referent1.id}")
      check("referent_#{referent2.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)

      within(".active-filter-badge", text: "Suivi par #{referent1}") do
        find("i.ri-close-line").click
      end

      expect(page).to have_no_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)

      expect(current_url.scan("referent_ids%5B%5D").count).to eq(1)
    end
  end

  context "with orientation type filters" do
    it "can select, deselect orientation types and remove filter by clicking on the cross" do
      click_button("Type d'orientation")
      check("orientation_type_#{orientation_type1.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_no_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)
      expect(current_url.scan("orientation_type_ids%5B%5D").count).to eq(1)

      click_button("Type d'orientation")
      check("orientation_type_#{orientation_type2.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)
      expect(current_url.scan("orientation_type_ids%5B%5D").count).to eq(2)

      click_button("Type d'orientation")
      uncheck("orientation_type_#{orientation_type1.id}")
      uncheck("orientation_type_#{orientation_type2.id}")
      click_button("Appliquer")

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_content(user3.first_name)
      expect(current_url.scan("orientation_type_ids%5B%5D").count).to eq(0)

      click_button("Type d'orientation")
      check("orientation_type_#{orientation_type1.id}")
      check("orientation_type_#{orientation_type2.id}")
      click_button("Appliquer")

      within(".active-filter-badge", text: "Orientation : #{orientation_type1.name}") do
        find("i.ri-close-line").click
      end

      expect(page).to have_no_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_no_content(user3.first_name)
      expect(current_url.scan("orientation_type_ids%5B%5D").count).to eq(1)

      within(".active-filter-badge", text: "Orientation : #{orientation_type2.name}") do
        find("i.ri-close-line").click
      end

      expect(page).to have_content(user1.first_name)
      expect(page).to have_content(user2.first_name)
      expect(page).to have_content(user3.first_name)
      expect(current_url.scan("orientation_type_ids%5B%5D").count).to eq(0)
    end
  end
end
