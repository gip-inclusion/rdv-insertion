describe "Super admin can manage templates" do
  let!(:super_admin) { create(:agent, :super_admin_verified) }
  let!(:template) { create(:template) }
  let!(:motif_category) { create(:motif_category, template: template) }

  before do
    setup_agent_session(super_admin)
  end

  context "from templates admin index page" do
    before { visit super_admins_templates_path }

    it "can see the list of templates" do
      expect(page).to have_current_path(super_admins_templates_path)
      expect(page).to have_content(template.id)
      expect(page).to have_content(template.rdv_subject)
      expect(page).to have_content(template.rdv_title)
      expect(page).to have_content(template.rdv_purpose)
      expect(page).to have_content(template.model)
    end

    it "can navigate to a template show page" do
      expect(page).to have_link(href: super_admins_template_path(template))

      first(:link, href: super_admins_template_path(template)).click

      expect(page).to have_current_path(super_admins_template_path(template))
    end

    it "cannot create a template" do
      expect(page).to have_no_link("Création template")
    end

    it "cannot edit a template" do
      expect(page).to have_no_link("Modifier")
    end

    it "cannot delete a template" do
      expect(page).to have_no_link("Supprimer")
    end
  end

  context "from template admin show page" do
    before { visit super_admins_template_path(template) }

    it "can see a template's details" do
      expect(page).to have_current_path(super_admins_template_path(template))
      expect(page).to have_content("Détails #{template.name}")
      expect(page).to have_css("dt", id: "id", text: "ID")
      expect(page).to have_css("dd", class: "attribute-data", text: template.id)
      expect(page).to have_css("dt", id: "model", text: "MODÈLE")
      expect(page).to have_css("dd", class: "attribute-data", text: template.model)
      expect(page).to have_css("dt", id: "rdv_subject", text: "THÈME DU RDV")
      expect(page).to have_css("dd", class: "attribute-data", text: template.rdv_subject)
      expect(page).to have_css("dt", id: "rdv_title", text: "TITRE DU RENDEZ-VOUS")
      expect(page).to have_css("dd", class: "attribute-data", text: template.rdv_title)
      expect(page).to have_css("dt", id: "rdv_title_by_phone", text: "TITRE DU RENDEZ-VOUS TÉLÉPHONIQUE")
      expect(page).to have_css("dd", class: "attribute-data", text: template.rdv_title_by_phone)
      expect(page).to have_css("dt", id: "rdv_purpose", text: "BUT DU RENDEZ-VOUS")
      expect(page).to have_css("dd", class: "attribute-data", text: template.rdv_purpose)
      expect(page).to have_css("dt", id: "user_designation", text: "DÉSIGNATION DE LA PERSONNE")
      expect(page).to have_css("dd", class: "attribute-data", text: template.user_designation)
      expect(page).to have_css("dt", id: "display_mandatory_warning", text: "RENDEZ-VOUS OBLIGATOIRE?")
      expect(page).to have_css("dd", class: "attribute-data", text: template.display_mandatory_warning)
      expect(page).to have_css("dt", id: "motif_categories", text: "MOTIF CATEGORIES")
      expect(page).to have_css("tr", class: "js-table-row", count: 1)
      within("tr.js-table-row") { expect(page).to have_link(motif_category.name, class: "action-show") }
    end

    it "cannot edit a template" do
      expect(page).to have_no_link("Modifier #{template.name}")
    end

    it "cannot delete a template" do
      expect(page).to have_no_link("Supprimer")
    end
  end

  context "when the agent is not a super admin" do
    let!(:agent) { create(:agent, super_admin: false) }

    before do
      setup_agent_session(agent)
    end

    it "cannot access the index page" do
      visit super_admins_templates_path

      expect(page).to have_current_path(organisations_path)
    end

    it "cannot access the show page" do
      visit super_admins_template_path(template)

      expect(page).to have_current_path(organisations_path)
    end
  end
end
