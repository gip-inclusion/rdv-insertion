describe "Super admin can manage departments" do
  let!(:super_admin) { create(:agent, :super_admin_verified) }
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }

  before do
    setup_agent_session(super_admin)
  end

  context "from departments admin index page" do
    before { visit super_admins_departments_path }

    it "can see the list of departments" do
      expect(page).to have_current_path(super_admins_departments_path)
      expect(page).to have_content(department.id)
      expect(page).to have_content(department.name)
      expect(page).to have_content(department.number)
      expect(page).to have_content("1 Organisation")
    end

    it "can navigate to a department show page" do
      expect(page).to have_link(href: super_admins_department_path(department))

      first(:link, href: super_admins_department_path(department)).click

      expect(page).to have_current_path(super_admins_department_path(department))
    end

    it "can navigate to a department new page" do
      expect(page).to have_link("Création département", href: new_super_admins_department_path)

      click_link(href: new_super_admins_department_path)

      expect(page).to have_current_path(new_super_admins_department_path)
    end

    it "can navigate to a department edit page" do
      expect(page).to have_link("Modifier", href: edit_super_admins_department_path(department))

      click_link(href: edit_super_admins_department_path(department))

      expect(page).to have_current_path(edit_super_admins_department_path(department))
    end

    it "cannot delete a department" do
      expect(page).to have_no_link("Supprimer")
    end
  end

  context "from department admin show page" do
    before { visit super_admins_department_path(department) }

    it "can see a department's details" do
      expect(page).to have_current_path(super_admins_department_path(department))
      expect(page).to have_content("Détails #{department.name}")
      expect(page).to have_css("dt", id: "id", text: "ID")
      expect(page).to have_css("dd", class: "attribute-data", text: department.id)
      expect(page).to have_css("dt", id: "pronoun", text: "PRONOM")
      expect(page).to have_css("dd", class: "attribute-data", text: department.pronoun)
      expect(page).to have_css("dt", id: "name", text: "NOM")
      expect(page).to have_css("dd", class: "attribute-data", text: department.name)
      expect(page).to have_css("dt", id: "capital", text: "CHEF-LIEU")
      expect(page).to have_css("dd", class: "attribute-data", text: department.capital)
      expect(page).to have_css("dt", id: "number", text: "NUMÉRO")
      expect(page).to have_css("dd", class: "attribute-data", text: department.number)
      expect(page).to have_css("dt", id: "region", text: "RÉGION")
      expect(page).to have_css("dd", class: "attribute-data", text: department.region)
      expect(page).to have_css("dt", id: "email", text: "EMAIL")
      expect(page).to have_css("dd", class: "attribute-data", text: department.email)
      expect(page).to have_css("dt", id: "phone_number", text: "TÉLÉPHONE")
      expect(page).to have_css("dd", class: "attribute-data", text: department.phone_number)
      expect(page).to have_css("dt", id: "display_in_stats", text: "AFFICHER DANS LES STATISTIQUES")
      expect(page).to have_css("dt", id: "organisations", text: "ORGANISATIONS")
      expect(page).to have_css("tr", class: "js-table-row", count: 1)
      expect(page).to have_css("a", class: "action-show")
      expect(page).to have_css("a[href=\"#{super_admins_organisation_path(organisation)}\"]")
    end

    it "can navigate to a department edit page" do
      expect(page).to have_link("Modifier #{department.name}", href: edit_super_admins_department_path(department))

      click_link("Modifier #{department.name}")

      expect(page).to have_current_path(edit_super_admins_department_path(department))
    end

    it "cannot delete a department" do
      expect(page).to have_no_link("Supprimer")
    end
  end

  context "from department admin new page" do
    before { visit new_super_admins_department_path }

    it "can create a department" do
      expect(page).to have_current_path(new_super_admins_department_path)
      expect(page).to have_content("Création Département")
      expect(page).to have_css("label[for=\"department_pronoun\"]", text: "Pronom")
      expect(page).to have_field("department[pronoun]")
      expect(page).to have_css("label[for=\"department_name\"]", text: "Nom")
      expect(page).to have_field("department[name]")
      expect(page).to have_css("label[for=\"department_capital\"]", text: "Chef-lieu")
      expect(page).to have_field("department[capital]")
      expect(page).to have_css("label[for=\"department_number\"]", text: "Numéro")
      expect(page).to have_field("department[number]")
      expect(page).to have_css("label[for=\"department_region\"]", text: "Région")
      expect(page).to have_field("department[region]")
      expect(page).to have_css("label[for=\"department_email\"]", text: "Email")
      expect(page).to have_field("department[email]")
      expect(page).to have_css("label[for=\"department_phone_number\"]", text: "Téléphone")
      expect(page).to have_field("department[phone_number]")
      expect(page).to have_css("label[for=\"department_display_in_stats\"]", text: "Afficher dans les statistiques")
      expect(page).to have_field("department[display_in_stats]")
      expect(page).to have_button("Enregistrer")

      fill_in "department_pronoun", with: "les"
      fill_in "department_name", with: "Yvelines"
      fill_in "department_capital", with: "Versailles"
      fill_in "department_number", with: "78"
      fill_in "department_region", with: "Ile-de-France"
      attach_file("department[logo]", Rails.root.join("spec/fixtures/logo.png"))

      click_button("Enregistrer")

      expect(page).to have_content("Département a été correctement créé(e)", wait: 10)
      expect(page).to have_content("Détails Yvelines", wait: 10)
      expect(page).to have_current_path(super_admins_department_path(Department.last))
    end

    context "when a required attribute is missing" do
      it "returns an error" do
        fill_in "department_pronoun", with: "les"
        fill_in "department_name", with: "Yvelines"
        fill_in "department_capital", with: "Versailles"

        click_button("Enregistrer")

        expect(page).to have_content("3 erreur ont empêché Département d'être sauvegardé(e)")
        expect(page).to have_content("Numéro doit être rempli(e)")
        expect(page).to have_content("Région doit être rempli(e)")
        expect(page).to have_content("Logo doit être rempli(e)")
        expect(page).to have_no_content("Détails Yvelines")
      end
    end
  end

  context "from department admin edit page" do
    before { visit edit_super_admins_department_path(department) }

    it "can edit a department" do
      expect(page).to have_current_path(edit_super_admins_department_path(department))
      expect(page).to have_content("Modifier #{department.name}")
      expect(page).to have_css("label[for=\"department_pronoun\"]", text: "Pronom")
      expect(page).to have_field("department[pronoun]", with: department.pronoun)
      expect(page).to have_css("label[for=\"department_name\"]", text: "Nom")
      expect(page).to have_field("department[name]", with: department.name)
      expect(page).to have_css("label[for=\"department_capital\"]", text: "Chef-lieu")
      expect(page).to have_field("department[capital]", with: department.capital)
      expect(page).to have_css("label[for=\"department_number\"]", text: "Numéro")
      expect(page).to have_field("department[number]", with: department.number)
      expect(page).to have_css("label[for=\"department_region\"]", text: "Région")
      expect(page).to have_field("department[region]", with: department.region)
      expect(page).to have_css("label[for=\"department_email\"]", text: "Email")
      expect(page).to have_field("department[email]", with: department.email)
      expect(page).to have_css("label[for=\"department_phone_number\"]", text: "Téléphone")
      expect(page).to have_field("department[phone_number]", with: department.phone_number)
      expect(page).to have_css("label[for=\"department_display_in_stats\"]", text: "Afficher dans les statistiques")
      expect(page).to have_field("department[display_in_stats]")
      expect(page).to have_button("Enregistrer")

      fill_in "department_name", with: "Yvelines"

      click_button("Enregistrer")

      expect(page).to have_current_path(super_admins_department_path(department))
      expect(page).to have_content("Département a été correctement modifié(e)")
      expect(page).to have_content("Détails Yvelines")
    end

    context "when a required attribute is missing" do
      it "returns an error" do
        fill_in "department_name", with: ""

        click_button("Enregistrer")

        expect(page).to have_content("1 erreur ont empêché Département d'être sauvegardé(e)")
        expect(page).to have_content("Nom doit être rempli(e)")
        expect(page).to have_no_content("Détails Yvelines")
      end
    end
  end

  context "when the agent is not a super admin" do
    let!(:agent) { create(:agent, super_admin: false) }

    before do
      setup_agent_session(agent)
    end

    it "cannot access the index page" do
      visit super_admins_departments_path

      expect(page).to have_current_path(organisations_path)
    end

    it "cannot access the new page" do
      visit new_super_admins_department_path(department)

      expect(page).to have_current_path(organisations_path)
    end

    it "cannot access the show page" do
      visit super_admins_department_path(department)

      expect(page).to have_current_path(organisations_path)
    end

    it "cannot access the edit page" do
      visit edit_super_admins_department_path(department)

      expect(page).to have_current_path(organisations_path)
    end
  end
end
