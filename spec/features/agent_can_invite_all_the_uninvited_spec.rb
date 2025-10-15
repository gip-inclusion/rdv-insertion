describe "Agent can invite all the uninvited", :js do
  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation, agents: [agent]) }
  let!(:uninvited_user) { create(:user, organisations: [organisation]) }
  let!(:motif_category) { create(:motif_category) }
  let!(:category_configuration) { create(:category_configuration, organisation: organisation, motif_category: motif_category) }
  let!(:invited_user) { create(:user, organisations: [organisation]) }
  let!(:invited_follow_up) { create(:follow_up, user: invited_user, motif_category: motif_category) }
  let!(:uninvited_follow_up) { create(:follow_up, user: uninvited_user, motif_category: motif_category) }
  let!(:invitation) { create(:invitation, follow_up: invited_follow_up, user: invited_user) }

  before do
    setup_agent_session(agent)
    invited_follow_up.set_status
    invited_follow_up.save!
    uninvited_follow_up.set_status
    uninvited_follow_up.save!
  end

  it "can invite all the uninvited" do
    visit organisation_users_path(organisation, motif_category_id: motif_category.id)
    expect(page).to have_content(uninvited_user.last_name)
    expect(page).to have_content(invited_user.last_name)

    click_button("Inviter les non-invités")
    expect(page).to have_content("Envoyer des invitations aux usagers non invités")
    expect(page).to have_content(uninvited_user.last_name)
    expect(page).to have_no_content(invited_user.last_name)
    expect(UserListUpload.count).to eq(1)
    expect(UserListUpload::UserRow.count).to eq(1)

    user_row = UserListUpload::UserRow.first
    expect(user_row.selected_for_invitation).to be_truthy
    expect(user_row.user).to eq(uninvited_user)
    expect(user_row.user_list_upload).to eq(UserListUpload.first)
    expect(user_row.user_list_upload.motif_category).to eq(motif_category)
    expect(user_row.user_list_upload.origin).to eq("invite_all_uninvited_button")
    expect(user_row.matching_user).to eq(uninvited_user)
  end
end