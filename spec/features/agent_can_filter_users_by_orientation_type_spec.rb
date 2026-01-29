describe "Agents can sort users by orientation on index page", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation) }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }
  let!(:user1) { create(:user, first_name: "Bertrand", last_name: "Blier") }
  let!(:user2) { create(:user, first_name: "Amanda", last_name: "Ajer") }
  let!(:user3) { create(:user, first_name: "Claire", last_name: "Casubolo") }

  let!(:users_organisation1) do
    create(:users_organisation, user: user1, organisation: organisation, created_at: Time.zone.now)
  end
  let!(:users_organisation2) do
    create(:users_organisation, user: user2, organisation: organisation, created_at: 1.day.ago)
  end
  let!(:users_organisation3) do
    create(:users_organisation, user: user3, organisation: organisation, created_at: 2.days.ago)
  end

  let(:orientation_type) { create(:orientation_type, name: "Sociale", casf_category: "social") }
  let!(:orientation) { create(:orientation, organisation: organisation, user: user1, orientation_type:) }

  before do
    setup_agent_session(agent)
    visit organisation_users_path(organisation, orientation_type_ids: [orientation_type.id])
  end

  it "filters users" do
    expect(page).to have_content("orientation")
    expect(page).to have_content(user1.first_name)
    expect(page).to have_no_content(user2.first_name)
    expect(page).to have_no_content(user3.first_name)
  end

  context "with orientations for user that are no longer in current org" do
    let!(:user4) { create(:user, first_name: "Diane", last_name: "Dujardin") }
    let!(:users_organisation4) do
      create(:users_organisation, user: user4, organisation: organisation2, created_at: 3.days.ago)
    end

    let!(:organisation2) { create(:organisation) }

    let!(:orientation2) do
      create(:orientation, organisation: organisation2, user: user4, orientation_type: orientation_type2)
    end
    let(:orientation_type2) { create(:orientation_type, name: "Coucou", casf_category: "pro") }

    before do
      create(:users_organisation, user: user2, organisation: organisation2)
      visit organisation_users_path(organisation)
    end

    it "does not show Coucou in orientation filters" do
      expect(page).to have_no_content(orientation_type2.name)
    end
  end
end
