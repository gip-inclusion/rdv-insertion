describe "Agent can see users index without category configuration", :js do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department:) }

  before do
    setup_agent_session(agent)
  end

  context "at organisation level" do
    context "when agent is admin" do
      let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

      context "without users" do
        it "displays the empty state with configure button" do
          visit organisation_users_path(organisation)

          expect(page).to have_content("Il n'y a pas encore d'usagers dans votre organisation")
          expect(page).to have_content("Commencez par configurer l'organisation")
          expect(page).to have_link("Configurer l'organisation")
        end

        it "displays the create category link in tabs" do
          visit organisation_users_path(organisation)

          expect(page).to have_link("+ Créer une catégorie")
        end
      end

      context "with users" do
        let!(:user) { create(:user, organisations: [organisation]) }

        it "displays the users list" do
          visit organisation_users_path(organisation)

          expect(page).to have_content(user.last_name)
          expect(page).to have_content(user.first_name)
        end

        it "displays the create category link in tabs" do
          visit organisation_users_path(organisation)

          expect(page).to have_link("+ Créer une catégorie")
        end
      end
    end

    context "when agent is not admin" do
      let!(:agent) { create(:agent, organisations: [organisation]) }

      context "without users" do
        it "displays the non-admin empty state" do
          visit organisation_users_path(organisation)

          expect(page).to have_content("L'organisation n'est pas encore prête")
          expect(page).to have_content("Rapprochez-vous de votre administrateur")
          expect(page).to have_no_link("Configurer l'organisation")
        end

        it "displays the no category configured text in tabs" do
          visit organisation_users_path(organisation)

          expect(page).to have_content("Aucune catégorie configurée")
          expect(page).to have_no_link("+ Créer une catégorie")
        end
      end

      context "with users" do
        let!(:user) { create(:user, organisations: [organisation]) }

        it "displays the users list" do
          visit organisation_users_path(organisation)

          expect(page).to have_content(user.last_name)
          expect(page).to have_content(user.first_name)
        end

        it "displays the no category configured text in tabs" do
          visit organisation_users_path(organisation)

          expect(page).to have_content("Aucune catégorie configurée")
        end
      end
    end

    context "on archived tab without archived users" do
      let!(:agent) { create(:agent, organisations: [organisation]) }

      it "displays the no archived users message" do
        visit organisation_users_path(organisation, users_scope: "archived")

        expect(page).to have_content("Il n'y a pas encore d'usagers archivés")
      end
    end
  end

  context "at department level" do
    let!(:agent) { create(:agent, organisations: [organisation]) }

    context "without users" do
      it "displays the department empty state" do
        visit department_users_path(department)

        expect(page).to have_content("Il n'y a pas encore d'usagers dans votre département")
        expect(page).to have_no_link("+ Créer une catégorie")
        expect(page).to have_no_content("Aucune catégorie configurée")
      end
    end

    context "with users" do
      let!(:user) { create(:user, organisations: [organisation]) }

      it "displays the users list" do
        visit department_users_path(department)

        expect(page).to have_content(user.last_name)
        expect(page).to have_content(user.first_name)
      end
    end

    context "on archived tab without archived users" do
      it "displays the no archived users message" do
        visit department_users_path(department, users_scope: "archived")

        expect(page).to have_content("Il n'y a pas encore d'usagers archivés")
      end
    end
  end
end
