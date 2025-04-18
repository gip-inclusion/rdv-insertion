describe "Agents can see convocation history", :js do
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
      follow_up: follow_up, rdv: rdv, user: user, status: "unknown", convocable: true,
      created_at: Time.zone.parse("2022-06-19 10:30")
    )
  end
  let!(:rdv) do
    create(
      :rdv,
      starts_at: Time.zone.parse("2022-06-22 08:30"), organisation: organisation, lieu: lieu,
      motif: motif
    )
  end
  let!(:excused_participation) do
    create(
      :participation,
      follow_up: follow_up, status: "excused", rdv: excused_rdv, user: user, convocable: true,
      created_at: Time.zone.parse("2022-06-14 10:30")
    )
  end
  let!(:excused_rdv) do
    create(
      :rdv,
      starts_at: Time.zone.parse("2022-06-15 10:30"), organisation: organisation, lieu: lieu,
      motif: motif
    )
  end
  let!(:existing_sms_notification) do
    create(:notification, participation: excused_participation, event: "participation_created", format: "sms",
                          delivery_status: "delivered",
                          last_brevo_webhook_received_at: Time.zone.parse("2022-06-16 11:30"),
                          created_at: Time.zone.parse("2022-06-14 11:30"))
  end

  let!(:existing_email_notification) do
    create(:notification, participation: excused_participation, event: "participation_created", format: "email",
                          delivery_status: "error", last_brevo_webhook_received_at: Time.zone.parse("2022-06-15 10:30"),
                          created_at: Time.zone.parse("2022-06-14 10:30"))
  end
  let!(:very_old_revoked_participation) do
    create(
      :participation,
      follow_up: follow_up, status: "revoked", rdv: very_old_revoked_rdv, user: user, convocable: true,
      created_at: Time.zone.parse("2021-08-08 10:30")
    )
  end
  let!(:very_old_revoked_rdv) do
    create(
      :rdv,
      starts_at: Time.zone.parse("2021-08-20 10:30"), organisation: organisation, lieu: lieu,
      motif: motif
    )
  end
  let!(:very_old_existing_sms_notification) do
    create(:notification, participation: very_old_revoked_participation, event: "participation_created", format: "sms",
                          delivery_status: "error", last_brevo_webhook_received_at: Time.zone.parse("2021-08-10 11:30"),
                          created_at: Time.zone.parse("2021-08-08 11:30"))
  end

  let!(:very_old_existing_email_notification) do
    create(:notification, participation: very_old_revoked_participation, event: "participation_created",
                          format: "email", delivery_status: "delivered",
                          last_brevo_webhook_received_at: Time.zone.parse("2021-08-09 10:30"),
                          created_at: Time.zone.parse("2021-08-08 10:30"))
  end

  let!(:very_old_existing_postal_notification) do
    create(:notification, participation: very_old_revoked_participation, event: "participation_created",
                          format: "postal", created_at: Time.zone.parse("2021-08-08 10:30"))
  end

  let!(:lieu) { create(:lieu, organisation: organisation) }

  before do
    travel_to(Time.zone.parse("2022-06-20"))
    setup_agent_session(agent)
    allow_any_instance_of(NotificationsController)
      .to receive(:pdf_request).and_wrap_original do |original_method, *_args|
      notification_content = original_method.receiver.send(:notify_participation).notification.content
      stub_pdf_service(sample_text: notification_content)
      instance_double(Faraday::Response, success?: true, body: Base64.encode64(notification_content))
    end
  end

  it "can click on more history and check individual notification status delivery" do
    visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)
    click_button "Voir l'historique"

    within("tr.motif-category-1-last-convocable_participations") do
      # Vérification de la notification SMS
      within all("td")[0] { expect(page).to have_content("-") }
      # Vérification de la notification email
      within all("td")[1] { expect(page).to have_content("-") }
      # Vérification de la notification postal
      within all("td")[2] { expect(page).to have_button "Télécharger le courrier" }
    end

    within all("tr.motif-category-1-other-convocable_participations")[0] do
      within all("td")[0] do
        expect(page).to have_content("14/06/2022")
        expect(page).to have_content("Délivrée à 11:30 (le 16/06/2022)")
      end

      within all("td")[1] do
        expect(page).to have_content("14/06/2022")
        within ".text-danger" do
          expect(page).to have_content("Non délivrée")
        end
        expect(page).to have_css("i.ri-error-warning-fill")
      end
    end

    within all("tr.motif-category-1-other-convocable_participations")[1] do
      within all("td")[0] do
        expect(page).to have_content("08/08/2021")
        within ".text-danger" do
          expect(page).to have_content("Non délivrée")
        end
        expect(page).to have_css("i.ri-error-warning-fill")
      end

      within all("td")[1] do
        expect(page).to have_content("08/08/2021")
        expect(page).to have_content("Délivrée à 10:30 (le 09/08/2021)")
      end
    end
  end

  it "can still download the pdf for the new convocation" do
    visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)
    click_button "Télécharger le courrier"

    wait_for_download
    expect(downloads.length).to eq(1)
    expect(Notification.last.format).to eq("postal")
    expect(Notification.last.delivery_status).to eq(nil)

    pdf = download_content(format: "pdf")
    pdf_text = extract_raw_text(pdf)

    expect(pdf_text).to include(lieu.name)
    expect(pdf_text).to include(lieu.address)
    expect(pdf_text).to include("mercredi 22 juin 2022 à 08h30")
  end
end
