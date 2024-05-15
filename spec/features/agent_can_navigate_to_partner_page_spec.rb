describe "Agents can navigate to partner page", :js do
  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation, agents: [agent]) }
  let!(:user) do
    create(
      :user,
      organisations: [organisation], affiliation_number: "1122233", role: "demandeur"
    )
  end

  before { setup_agent_session(agent) }

  context "when the user does not have a partner" do
    it "does not show a link to the partner page" do
      visit organisation_user_path(user, organisation_id: organisation.id)

      expect(page).to have_content(user.affiliation_number)
      expect(page).to have_content(user.role)

      expect(page).to have_no_content("Voir le conjoint")
    end
  end

  context "when the user has a partner" do
    let!(:conjoint) do
      create(:user, affiliation_number: "1122233", role: "conjoint", organisations: [organisation])
    end

    it "shows a link to the partner page" do
      visit organisation_user_path(user, organisation_id: organisation.id)

      expect(page).to have_content(user.affiliation_number)
      expect(page).to have_content(user.role)

      expect(page).to have_link("Voir le conjoint")
      new_window = window_opened_by { click_link("Voir le conjoint") }
      within_window new_window do
        expect(page).to have_content(conjoint.first_name)
        expect(page).to have_content(conjoint.last_name)
        expect(page).to have_link("Voir le demandeur")
      end
    end

    context "when the partner does not belong to user org" do
      let!(:conjoint) do
        create(:user, affiliation_number: "1122233", role: "conjoint", organisations: [create(:organisation)])
      end

      it "does not show a link to the partner page" do
        visit organisation_user_path(user, organisation_id: organisation.id)

        expect(page).to have_content(user.affiliation_number)
        expect(page).to have_content(user.role)

        expect(page).to have_no_content("Voir le conjoint")
      end
    end
  end
end
