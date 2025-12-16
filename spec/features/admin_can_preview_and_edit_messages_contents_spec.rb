describe "Admins can preview and editmessages contents", :js do
  include_context "with all existing categories"

  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation, department: create(:department, number: "26")) }
  let!(:agent_role) { create(:agent_role, agent:, organisation:, access_level: "admin") }
  let!(:category_configuration) do
    create(
      :category_configuration, motif_category: category_rsa_orientation, organisation:,
      convene_user: true
    )
  end

  before { setup_agent_session(agent) }

  it "can preview and edit messages contents" do
    visit organisation_configuration_messages_path(organisation)

    expect(page).to have_link("Convocations")
    expect(page).to have_link("Invitations")

    # Default values
    expect(page).to have_content("rendez-vous d'orientation")
    expect(page).to have_content("rendez-vous d'orientation téléphonique")
    expect(page).to have_content("bénéficiaire du RSA")
    expect(page).to have_content("démarrer un parcours d'accompagnement")

    click_link("Invitations")

    expect(page).to have_css("span.text-violet", text: "rendez-vous d'orientation", wait: 20)
    expect(page).to have_css("span.text-violet", text: "bénéficiaire du RSA")
    expect(page).to have_css("span.text-violet", text: "démarrer un parcours d'accompagnement")

    find("button.btn-close").click

    expect(page).to have_link("Convocations")
    expect(page).to have_link("Invitations")

    click_link("Convocations")

    expect(page).to have_css("span.text-violet", text: "rendez-vous d'orientation téléphonique", wait: 20)
    expect(page).to have_css("span.text-violet", text: "rendez-vous d'orientation")
    expect(page).to have_css("span.text-violet", text: "bénéficiaire du RSA")
    expect(page).to have_css("span.text-violet", text: "démarrer un parcours d'accompagnement")

    expect(page).to have_css("button.btn-close")
    find("button.btn-close").click

    expect(page).to have_link("Modifier")

    within "turbo-frame#category_configuration_template_overrides_#{category_configuration.id}" do
      click_link("Modifier")
    end

    expect(page).to have_field(
      "category_configuration_template_rdv_title_override",
      placeholder: "rendez-vous d'orientation (par défaut)"
    )
    expect(page).to have_field(
      "category_configuration_template_rdv_title_by_phone_override",
      placeholder: "rendez-vous d'orientation téléphonique (par défaut)"
    )
    expect(page).to have_field(
      "category_configuration_template_user_designation_override",
      placeholder: "bénéficiaire du RSA (par défaut)"
    )
    expect(page).to have_field(
      "category_configuration_template_rdv_purpose_override",
      placeholder: "démarrer un parcours d'accompagnement (par défaut)"
    )

    expect(page).to have_button("Invitations", disabled: true)
    expect(page).to have_button("Convocations", disabled: true)

    page.fill_in "category_configuration_template_rdv_title_override", with: "nouveau type de rendez-vous"
    page.fill_in "category_configuration_template_rdv_title_by_phone_override", with: "nouveau coup de téléphone"
    page.fill_in "category_configuration_template_user_designation_override", with: "une personne remarquable"
    page.fill_in "category_configuration_template_rdv_purpose_override", with: "vous rencontrer"

    click_button("Enregistrer")

    expect(page).to have_link("Invitations")

    click_link("Invitations")

    expect(page).to have_css("span.text-violet", text: "nouveau type de rendez-vous", wait: 20)
    expect(page).to have_css("span.text-violet", text: "une personne remarquable")
    expect(page).to have_css("span.text-violet", text: "vous rencontrer")

    expect(page).to have_no_css("span.text-violet", text: "rendez-vous d'orientation")
    expect(page).to have_no_css("span.text-violet", text: "bénéficiaire du RSA")
    expect(page).to have_no_css("span.text-violet", text: "démarrer un parcours d'accompagnement")

    find("button.btn-close").click

    expect(page).to have_link("Convocations")

    click_link("Convocations")

    expect(page).to have_css("span.text-violet", text: "nouveau type de rendez-vous", wait: 20)
    expect(page).to have_css("span.text-violet", text: "nouveau coup de téléphone")
    expect(page).to have_css("span.text-violet", text: "une personne remarquable")
    expect(page).to have_css("span.text-violet", text: "vous rencontrer")

    expect(page).to have_no_css("span.text-violet", text: "rendez-vous d'orientation téléphonique")
    expect(page).to have_no_css("span.text-violet", text: "rendez-vous d'orientation")
    expect(page).to have_no_css("span.text-violet", text: "bénéficiaire du RSA")
    expect(page).to have_no_css("span.text-violet", text: "démarrer un parcours d'accompagnement")
  end

  it "can cancel editing" do
    visit organisation_configuration_messages_path(organisation)
    within "turbo-frame#category_configuration_template_overrides_#{category_configuration.id}" do
      click_link("Modifier")
    end
    click_link("Annuler")
    expect(page).to have_link("Modifier")
    expect(page).to have_content("rendez-vous d'orientation")
    expect(page).to have_content("rendez-vous d'orientation téléphonique")
    expect(page).to have_content("bénéficiaire du RSA")
    expect(page).to have_content("démarrer un parcours d'accompagnement")
  end

  context "when the category does not require all the template variables and has no reminder" do
    let!(:category_configuration) do
      create(:category_configuration, motif_category: category_rsa_insertion_offer, organisation:)
    end

    it "still can preview contents" do
      visit organisation_configuration_messages_path(organisation)

      expect(page).to have_link("Convocations")
      expect(page).to have_link("Invitations")

      click_link("Invitations")

      expect(page).to have_css("span.text-violet", text: "bénéficiaire du RSA", wait: 20)
      expect(page).to have_content("atelier")

      find("button.btn-close").click

      expect(page).to have_link("Convocations")
      expect(page).to have_link("Invitations")

      click_link("Convocations")

      expect(page).to have_css("span.text-violet", text: "atelier", wait: 20)
      expect(page).to have_css("span.text-violet", text: "atelier téléphonique")
      expect(page).to have_css("span.text-violet", text: "bénéficiaire du RSA")
    end
  end

  context "when the category does not convene the user" do
    let!(:category_configuration) do
      create(
        :category_configuration, motif_category: category_rsa_insertion_offer, organisation:,
        convene_user: false
      )
    end

    it "disables the convocation link" do
      visit organisation_configuration_messages_path(organisation)
      expect(page).to have_no_link("Convocations")
      expect(page).to have_button("Convocations (désactivées)", disabled: true)
    end
  end
end
