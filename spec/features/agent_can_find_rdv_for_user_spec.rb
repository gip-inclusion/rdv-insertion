describe "Agents can edit users tags", :js do
  let!(:agent) { create(:agent, organisations: [organisation, other_organisation]) }
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, name: "orga 1", department:) }
  let!(:other_organisation) { create(:organisation, name: "orga 2", department:) }
  let!(:user) { create(:user, department: organisation.department, organisations: [organisation]) }

  before do
    setup_agent_session(agent)
  end

  context "when the user belongs to one org only" do
    it "shows only one link" do
      visit organisation_user_path(user, organisation_id: organisation.id)

      expect(page).to have_link("Trouver un RDV", href: new_user_rdv_path(user, organisation_id: organisation.id))

      expect(page).to have_no_content("Sur l'organisation orga 1")
      expect(page).to have_no_content("Sur l'organisation orga 2")
    end

    context "when the user belongs to two orgs" do
      let!(:user) { create(:user, department: organisation.department, organisations: [organisation, other_organisation]) }

      it "shows two links" do
        visit organisation_user_path(user, organisation_id: organisation.id)
        click_button("Trouver un RDV")

        expect(page).to have_link("Sur l'organisation orga 1",
                                  href: new_user_rdv_path(user, organisation_id: organisation.id))
        expect(page).to have_link("Sur l'organisation orga 2",
                                  href: new_user_rdv_path(user, organisation_id: other_organisation.id))
      end

      context "when the agent belongs to one org only" do
        let!(:agent) { create(:agent, organisations: [organisation]) }

        it "shows only one link" do
          visit organisation_user_path(user, organisation_id: organisation.id)

          expect(page).to have_link("Trouver un RDV", href: new_user_rdv_path(user, organisation_id: organisation.id))

          expect(page).to have_no_content("Sur l'organisation orga 1")
          expect(page).to have_no_content("Sur l'organisation orga 2")
        end
      end

      context "when the second org is in another department" do
        let!(:other_organisation) { create(:organisation, name: "orga 2", department: create(:department)) }

        it "shows only one link" do
          visit organisation_user_path(user, organisation_id: organisation.id)

          expect(page).to have_link("Trouver un RDV", href: new_user_rdv_path(user, organisation_id: organisation.id))

          expect(page).to have_no_content("Sur l'organisation orga 1")
          expect(page).to have_no_content("Sur l'organisation orga 2")
        end
      end
    end
  end
end
