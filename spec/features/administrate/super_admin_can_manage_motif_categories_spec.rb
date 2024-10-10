describe "Super admin can manage motif categories" do
  let!(:super_admin) { create(:agent, :super_admin) }
  let!(:template) { create(:template) }
  let!(:motif_category) { create(:motif_category, template: template) }
  let!(:motif) { create(:motif, motif_category: motif_category) }

  before do
    setup_agent_session(super_admin)
  end

  context "from motif categories admin index page" do
    before { visit super_admins_motif_categories_path }

    it "can see the list of motif_categories" do
      expect(page).to have_current_path(super_admins_motif_categories_path)
      expect(page).to have_content(motif_category.id)
      expect(page).to have_content(motif_category.name)
    end

    it "can navigate to a motif_category show page" do
      expect(page).to have_link(href: super_admins_motif_category_path(motif_category))

      first(:link, href: super_admins_motif_category_path(motif_category)).click

      expect(page).to have_current_path(super_admins_motif_category_path(motif_category))
    end

    it "can navigate to a motif_category new page" do
      expect(page).to have_link("Création catégorie de motifs", href: new_super_admins_motif_category_path)

      click_link(href: new_super_admins_motif_category_path)

      expect(page).to have_current_path(new_super_admins_motif_category_path)
    end

    it "can navigate to a motif category edit page" do
      expect(page).to have_link("Modifier", href: edit_super_admins_motif_category_path(motif_category))

      click_link(href: edit_super_admins_motif_category_path(motif_category))

      expect(page).to have_current_path(edit_super_admins_motif_category_path(motif_category))
    end

    it "cannot delete a motif_category" do
      expect(page).to have_no_link("Supprimer")
    end
  end

  context "from motif cateogry admin show page" do
    before { visit super_admins_motif_category_path(motif_category) }

    it "can see a motif cateogry's details" do
      expect(page).to have_current_path(super_admins_motif_category_path(motif_category))
      expect(page).to have_content("Détails MotifCategory ##{motif_category.id}")
      expect(page).to have_css("dt", id: "id", text: "ID")
      expect(page).to have_css("dd", class: "attribute-data", text: motif_category.id)
      expect(page).to have_css("dt", id: "name", text: "NAME")
      expect(page).to have_css("dd", class: "attribute-data", text: motif_category.name)
      expect(page).to have_css("dt", id: "short_name", text: "SHORT NAME")
      expect(page).to have_css("dd", class: "attribute-data", text: motif_category.short_name)
      expect(page).to have_css("dt", id: "template", text: "TEMPLATE")
      expect(page).to have_link(motif_category.template.name, href: super_admins_template_path(template))
      expect(page).to have_css("dt", id: "motifs", text: "MOTIFS")
      expect(page).to have_css("tr", class: "js-table-row", count: 1)
      within("tr.js-table-row") { expect(page).to have_css("td.cell-data", text: motif.name) }
      expect(page).to have_css("dt", id: "motif_category_type", text: "TYPE DE CATÉGORIE")
      expect(page).to have_css("dd", class: "attribute-data", text: motif_category.motif_category_type)
    end

    it "can navigate to a motif category edit page" do
      expect(page).to have_link("Modifier", href: edit_super_admins_motif_category_path(motif_category))

      click_link(href: edit_super_admins_motif_category_path(motif_category))

      expect(page).to have_current_path(edit_super_admins_motif_category_path(motif_category))
    end

    it "cannot delete a motif_category" do
      expect(page).to have_no_link("Supprimer")
    end
  end

  context "from motif category admin new page" do
    before { visit new_super_admins_motif_category_path }

    it "can create a new motif category" do
      stub_create_motif_category = stub_request(
        :post, "#{ENV['RDV_SOLIDARITES_URL']}/api/rdvinsertion/motif_categories"
      ).to_return(status: 200, body: {}.to_json)

      expect(page).to have_current_path(new_super_admins_motif_category_path)
      expect(page).to have_content("Création Catégorie De Motifs")
      expect(page).to have_css("label[for=\"motif_category_name\"]", text: "Name")
      expect(page).to have_field("motif_category[name]")
      expect(page).to have_css("label[for=\"motif_category_short_name\"]", text: "Short name")
      expect(page).to have_field("motif_category[short_name]")
      expect(page).to have_css("label[for=\"motif_category_template_id-selectized\"]", text: "Template")
      expect(page).to have_field("motif_category_template_id-selectized")
      expect(page).to have_field("motif_category_motif_category_type-selectized")
      expect(page).to have_button("Enregistrer")

      fill_in "motif_category_name", with: "France Travail orientation"
      fill_in "motif_category_short_name", with: "france_travail_orientation"
      first("div.selectize-input").click(wait: 20)
      first("div.option", text: template.name).click

      click_button("Enregistrer")

      expect(stub_create_motif_category).to have_been_requested
      expect(page).to have_current_path(super_admins_motif_category_path(MotifCategory.last))
      expect(page).to have_content("Catégorie de motifs a été correctement créé(e)")
      expect(page).to have_content("Détails MotifCategory ##{MotifCategory.last.id}")
    end

    context "when a required attribute is missing" do
      it "returns an error" do
        stub_create_motif_category = stub_request(
          :post, "#{ENV['RDV_SOLIDARITES_URL']}/api/rdvinsertion/motif_categories"
        ).to_return(status: 200, body: {}.to_json)

        fill_in "motif_category_name", with: "France Travail orientation"
        fill_in "motif_category_short_name", with: "france_travail_orientation"

        click_button("Enregistrer")

        expect(stub_create_motif_category).not_to have_been_requested
        expect(page).to have_content("Template doit exister")
      end
    end
  end

  context "when the agent is not a super admin" do
    let!(:agent) { create(:agent, super_admin: false) }

    before do
      setup_agent_session(agent)
    end

    it "cannot access the index page" do
      visit super_admins_motif_categories_path

      expect(page).to have_current_path(organisations_path)
    end

    it "cannot access the new page" do
      visit new_super_admins_motif_category_path(motif_category)

      expect(page).to have_current_path(organisations_path)
    end

    it "cannot access the show page" do
      visit super_admins_motif_category_path(motif_category)

      expect(page).to have_current_path(organisations_path)
    end
  end
end
