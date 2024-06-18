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
    visit organisation_users_path(organisation, orientation_type: "Sociale")
  end

  it "filters users" do
    expect(page).to have_content("orientation")
    expect(page).to have_content(user1.first_name)
    expect(page).to have_no_content(user2.first_name)
    expect(page).to have_no_content(user3.first_name)
  end
end
