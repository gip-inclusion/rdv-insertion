describe "Agents can generate convocation pdf", :js do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation) }
  let!(:user) do
    create(:user, organisations: [organisation], title: "monsieur")
  end
  let!(:motif_category) { create(:motif_category) }
  let!(:motif) do
    create(:motif, organisation: organisation, motif_category: motif_category, location_type: "public_office")
  end
  let!(:follow_up) do
    create(:follow_up, motif_category: motif_category, user: user, status: "rdv_pending")
  end
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:participation) do
    create(
      :participation,
      follow_up: follow_up, rdv: rdv, user: user, status: "unknown", convocable: true
    )
  end
  let!(:rdv) do
    create(
      :rdv,
      starts_at: Time.zone.parse("2022-06-22 08:30"), organisation: organisation, lieu: lieu,
      motif: motif
    )
  end
  let!(:lieu) { create(:lieu, organisation: organisation) }

  before do
    travel_to(Time.zone.parse("2022-06-20"))
    setup_agent_session(agent)
  end

  context "when the pdf is generated" do
    before do
      stub_request(:post, "#{ENV['PDF_GENERATOR_URL']}/generate")
        .with(
          headers: {
            "Authorization" => ENV["PDF_GENERATOR_API_KEY"],
            "Content-Type" => "application/json"
          }
        )
        .to_return do |request|
          # we get the content of the notification from the request body
          request_body = JSON.parse(request.body)
          notification_content = request_body["htmlContent"]
          {
            status: 200,
            body: Base64.encode64(notification_content),
            headers: { "Content-Type" => "application/json" }
          }
      end
    end

    it "can generate a pdf" do
      visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

      expect(page).to have_button "Télécharger le courrier"

      click_button "Télécharger le courrier"

      wait_for_download
      expect(downloads.length).to eq(1)

      pdf_text = download_content

      expect(pdf_text).to include(lieu.name)
      expect(pdf_text).to include(lieu.address)
      expect(pdf_text).to include("mercredi 22 juin 2022 à 08h30")
    end

    context "when it is a phone rdv" do
      before { motif.update! location_type: "phone" }

      it "generates the matching pdf" do
        visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

        expect(page).to have_button "Télécharger le courrier"

        click_button "Télécharger le courrier"

        wait_for_download
        expect(downloads.length).to eq(1)

        pdf_text = download_content

        expect(pdf_text).not_to include(lieu.name)
        expect(pdf_text).not_to include(lieu.address)
        expect(pdf_text).to include(user.phone_number)
        expect(pdf_text).to include("mercredi 22 juin 2022 à 08h30")
      end
    end

    context "when the rdv is passed" do
      before { rdv.update! starts_at: 2.days.ago }

      it "cannot generate a pdf" do
        visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

        expect(page).to have_no_button "Télécharger le courrier"
      end
    end

    context "when the participation is excused" do
      before { participation.update! status: "excused" }

      it "cannot generate a pdf" do
        visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

        expect(page).to have_no_button "Télécharger le courrier"
      end
    end

    context "when the participation is revoked" do
      before { participation.update! status: "revoked" }

      it "can generate a revoked participation pdf" do
        visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

        expect(page).to have_button "Télécharger le courrier"

        click_button "Télécharger le courrier"

        wait_for_download
        expect(downloads.length).to eq(1)

        pdf_text = download_content

        expect(pdf_text).to include("a été annulé")
      end
    end
  end

  context "when the pdf cannot be generated" do
    before { user.update! address: "format invalide" }

    it "returns an error" do
      visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

      expect(page).to have_button "Télécharger le courrier"

      click_button "Télécharger le courrier"

      expect(page).to have_content(
        "Le format de l'adresse est invalide. Le format attendu est le suivant: 10 rue de l'envoi 12345 - La Ville"
      )

      expect(page).to have_button "Télécharger le courrier"
    end
  end

  context "when the PDF generation service fails" do
    before do
      stub_request(:post, "#{ENV['PDF_GENERATOR_URL']}/generate")
        .to_return(status: 500, body: "Erreur du service de génération de PDF")
      allow(Sentry).to receive(:capture_message)
    end

    it "shows an error message and allows retry" do
      visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)
      click_button "Télécharger le courrier"

      expect(page).to have_content(
        "Une erreur est survenue lors de la génération du PDF." \
        " L'équipe a été notifiée de l'erreur et tente de la résoudre."
      )
      expect(page).to have_button "Télécharger le courrier"
      expect(Sentry).to have_received(:capture_message).with(
        "PDF generation failed",
        extra: { status: 500, body: "Erreur du service de génération de PDF",
                 notification_id: Notification.last.id }
      )
    end
  end

  context "when the notification service fails" do
    before do
      allow(Notifications::SaveAndSend).to receive(:call)
        .and_return(OpenStruct.new(success?: false, errors: ["Erreur lors de la création de la notification"]))
    end

    it "shows an error message and allows retry" do
      visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)
      click_button "Télécharger le courrier"

      expect(page).to have_content("Erreur lors de la création de la notification")
      expect(page).to have_button "Télécharger le courrier"
    end
  end
end
