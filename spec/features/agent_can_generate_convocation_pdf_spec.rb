describe "Agents can generate convocation pdf", js: true do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation) }
  let!(:applicant) { create(:applicant, organisations: [organisation]) }
  let!(:motif_category) { create(:motif_category) }
  let!(:motif) do
    create(:motif, organisation: organisation, motif_category: motif_category, location_type: "public_office")
  end
  let!(:rdv_context) do
    create(:rdv_context, motif_category: motif_category, applicant: applicant, status: "rdv_pending")
  end
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: motif_category) }
  let!(:participation) do
    create(
      :participation,
      rdv_context: rdv_context, rdv: rdv, applicant: applicant, status: "unknown"
    )
  end
  let!(:rdv) do
    create(
      :rdv,
      convocable: true, starts_at: Time.zone.parse("2022-06-22 08:30"), organisation: organisation, lieu: lieu,
      motif: motif
    )
  end
  let!(:lieu) { create(:lieu, organisation: organisation) }

  before do
    travel_to(Time.zone.parse("2022-06-20"))
    setup_agent_session(agent)
  end

  it "can generate a pdf" do
    visit organisation_applicant_path(organisation, applicant)

    expect(page).to have_button "Courrier"

    click_button "Courrier"

    wait_for_download
    expect(downloads.length).to eq(1)

    pdf = download_content(format: "pdf")
    pdf_text = extract_raw_text(pdf)

    expect(pdf_text).to include(lieu.name)
    expect(pdf_text).to include(lieu.address)
    expect(pdf_text).to include("mercredi 22 juin 2022 à 08h30")
  end

  context "when it is a phone rdv" do
    before { motif.update! location_type: "phone" }

    it "generates the matching pdf" do
      visit organisation_applicant_path(organisation, applicant)

      expect(page).to have_button "Courrier"

      click_button "Courrier"

      wait_for_download
      expect(downloads.length).to eq(1)

      pdf = download_content(format: "pdf")
      pdf_text = extract_raw_text(pdf)

      expect(pdf_text).not_to include(lieu.name)
      expect(pdf_text).not_to include(lieu.address)
      expect(pdf_text).to include(applicant.phone_number)
      expect(pdf_text).to include("mercredi 22 juin 2022 à 08h30")
    end
  end

  context "when the rdv is passed" do
    before { rdv.update! starts_at: 2.days.ago }

    it "cannot generate a pdf" do
      visit organisation_applicant_path(organisation, applicant)

      expect(page).not_to have_button "Courrier"
    end

    context "when the participation is revoked" do
      before { participation.update! status: "revoked" }

      it "can generate a revoked participation pdf" do
        visit organisation_applicant_path(organisation, applicant)

        expect(page).to have_button "Courrier"

        click_button "Courrier"

        wait_for_download
        expect(downloads.length).to eq(1)

        pdf = download_content(format: "pdf")
        pdf_text = extract_raw_text(pdf)

        expect(pdf_text).to include("a été annulé")
      end
    end
  end

  context "when the pdf cannot be generated" do
    before { applicant.update! address: "format invalide" }

    it "returns an error" do
      visit organisation_applicant_path(organisation, applicant)

      expect(page).to have_button "Courrier"

      click_button "Courrier"

      expect(page).to have_content(
        "Le format de l'adresse est invalide. Le format attendu est le suivant: 10 rue de l'envoi 12345 - La Ville"
      )

      expect(page).to have_button "Courrier"
    end
  end
end
