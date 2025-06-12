describe "Agents can sort users on index page", :js do
  let!(:department) { create(:department) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }
  let!(:user1) { create(:user, first_name: "Bertrand", last_name: "Blier", department:) }
  let!(:user2) { create(:user, first_name: "Amanda", last_name: "Ajer", department:) }
  let!(:user3) { create(:user, first_name: "Claire", last_name: "Casubolo", department:) }

  before do
    setup_agent_session(agent)
  end

  shared_examples "a table with a working sorting" do |last_name_default_order, first_name_default_order|
    it "can sort by first name" do
      test_ordering_for(column_name: "first_name", column_index: 1, default_order: first_name_default_order)
    end

    it "can sort by last name" do
      test_ordering_for(column_name: "last_name", column_index: 0, default_order: last_name_default_order)
    end
  end

  context "on 'Tous les contacts' tab" do
    # on "Tous les contacts", users are sorted by user_org creation date by default
    let!(:users_organisation1) do
      create(:users_organisation, user: user1, organisation: organisation, created_at: Time.zone.now)
    end
    let!(:users_organisation2) do
      create(:users_organisation, user: user2, organisation: organisation, created_at: 1.day.ago)
    end
    let!(:users_organisation3) do
      create(:users_organisation, user: user3, organisation: organisation, created_at: 2.days.ago)
    end

    before do
      visit organisation_users_path(organisation)
    end

    it_behaves_like "a table with a working sorting", %w[Blier Ajer Casubolo], %w[Bertrand Amanda Claire]
  end

  context "on motif_category tab" do
    # on motif_category tab, users are sorted by follow_ups creation date by default
    let!(:organisation) { create(:organisation, users: [user1, user2, user3], department:) }
    let!(:follow_up1) { create(:follow_up, user: user1, motif_category: motif_category, created_at: Time.zone.now) }
    let!(:follow_up2) { create(:follow_up, user: user2, motif_category: motif_category, created_at: 1.day.ago) }
    let!(:follow_up3) { create(:follow_up, user: user3, motif_category: motif_category, created_at: 2.days.ago) }

    before do
      visit organisation_users_path(organisation, motif_category_id: motif_category.id)
    end

    # on "Tous les contacts", users are sorted by user_org creation date by default
    it_behaves_like "a table with a working sorting", %w[Blier Ajer Casubolo], %w[Bertrand Amanda Claire]
  end

  context "on archived users tab" do
    # on archived users tab, users are sorted by archives creation date by default
    let!(:organisation) { create(:organisation, users: [user1, user2, user3], department:) }
    let!(:archive1) { create(:archive, user: user1, created_at: Time.zone.now) }
    let!(:archive2) { create(:archive, user: user2, created_at: 1.day.ago) }
    let!(:archive3) { create(:archive, user: user3, created_at: 2.days.ago) }

    before do
      visit organisation_users_path(organisation, users_scope: "archived")
    end

    # on "Tous les contacts", users are sorted by user_org creation date by default
    it_behaves_like "a table with a working sorting", %w[Blier Ajer Casubolo], %w[Bertrand Amanda Claire]
  end
end
