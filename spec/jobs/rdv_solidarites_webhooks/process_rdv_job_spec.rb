describe RdvSolidaritesWebhooks::ProcessRdvJob, type: :job do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:user_id) { 42 }
  let!(:user_ids) { [user_id] }
  let!(:rdv_solidarites_rdv_id) { 22 }
  let!(:rdv_solidarites_organisation_id) { 52 }
  let!(:rdv_solidarites_lieu_id) { 43 }
  let!(:rdv_solidarites_motif_id) { 53 }
  let!(:lieu_attributes) { { id: rdv_solidarites_lieu_id, name: "DINUM", address: "20 avenue de Ségur" } }
  let!(:motif_attributes) { { id: 53, location: "public_office", category: "rsa_orientation" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }
  let!(:data) do
    {
      "id" => rdv_solidarites_rdv_id,
      "starts_at" => starts_at,
      "address" => "20 avenue de segur",
      "context" => "all good",
      "lieu" => lieu_attributes,
      "motif" => motif_attributes,
      "users" => [{ id: user_id }],
      "organisation" => { id: rdv_solidarites_organisation_id }
    }.deep_symbolize_keys
  end

  let!(:timestamp) { "2021-05-30 14:44:22 +0200" }
  let!(:meta) do
    {
      "model" => "Rdv",
      "event" => "created",
      "timestamp" => timestamp
    }.deep_symbolize_keys
  end

  let!(:applicant) { create(:applicant, organisations: [organisation], id: 3) }
  let!(:applicant2) { create(:applicant, organisations: [organisation], id: 4) }

  let!(:configuration) { create(:configuration, notify_applicant: true, motif_category: "rsa_orientation") }
  let!(:organisation) do
    create(
      :organisation,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id, configurations: [configuration]
    )
  end
  let!(:motif) { create(:motif, rdv_solidarites_motif_id: rdv_solidarites_motif_id) }
  let!(:lieu) do
    create(
      :lieu, rdv_solidarites_lieu_id: rdv_solidarites_lieu_id, name: "DINUM", address: "20 avenue de Ségur",
             organisation: organisation
    )
  end

  let!(:invitation) { create(:invitation, rdv_context: rdv_context) }
  let!(:invitation2) { create(:invitation, rdv_context: rdv_context2) }
  let!(:invitation3) { create(:invitation, rdv_context: rdv_context2) }

  let!(:rdv_context) do
    build(:rdv_context, motif_category: "rsa_orientation", applicant: applicant, id: 28)
  end

  let!(:rdv_context2) do
    build(:rdv_context, motif_category: "rsa_orientation", applicant: applicant2, id: 99)
  end

  describe "#perform" do
    before do
      allow(Applicant).to receive(:includes).and_return(Applicant)
      allow(Applicant).to receive(:where)
        .with(rdv_solidarites_user_id: user_ids)
        .and_return([applicant, applicant2])
      allow(RdvContext).to receive(:find_or_create_by!)
        .with(applicant: applicant, motif_category: "rsa_orientation")
        .and_return(rdv_context)
      allow(RdvContext).to receive(:find_or_create_by!)
        .with(applicant: applicant2, motif_category: "rsa_orientation")
        .and_return(rdv_context2)
      allow(UpsertRecordJob).to receive(:perform_async)
      allow(InvalidateInvitationJob).to receive(:perform_async)
      allow(DeleteRdvJob).to receive(:perform_async)
      allow(NotifyApplicantJob).to receive(:perform_async)
      allow(SendRdvSolidaritesWebhookJob).to receive(:perform_async)
      allow(MattermostClient).to receive(:send_to_notif_channel)
    end

    context "when no organisation is found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: "random-orga-id") }

      it "raises an error" do
        expect { subject }.to raise_error(WebhookProcessingJobError, "Organisation not found with id 52")
      end
    end

    context "when no motif is found" do
      let!(:motif) { create(:motif, rdv_solidarites_motif_id: "random-motif-id") }

      it "raises an error" do
        expect { subject }.to raise_error(WebhookProcessingJobError, "Motif not found with id 53")
      end
    end

    context "when no applicant is found" do
      before do
        allow(Applicant).to receive(:where)
          .with(rdv_solidarites_user_id: user_ids)
          .and_return([])
      end

      it "does not call the other jobs" do
        [UpsertRecordJob, DeleteRdvJob, NotifyApplicantJob, InvalidateInvitationJob].each do |klass|
          expect(klass).not_to receive(:perform_async)
        end
        subject
      end
    end

    context "it udpates the rdv" do
      it "enqueues an upsert job and an invalidation token job" do
        expect(UpsertRecordJob).to receive(:perform_async)
          .with(
            "Rdv",
            data,
            {
              applicant_ids: [applicant.id, applicant2.id],
              organisation_id: organisation.id,
              rdv_context_ids: [rdv_context.id, rdv_context2.id],
              motif_id: motif.id,
              lieu_id: lieu.id,
              last_webhook_update_received_at: timestamp
            }
          )
        expect(InvalidateInvitationJob).to receive(:perform_async).exactly(1).time.with(invitation.id)
        expect(InvalidateInvitationJob).to receive(:perform_async).exactly(1).time.with(invitation2.id)
        expect(InvalidateInvitationJob).to receive(:perform_async).exactly(1).time.with(invitation3.id)
        subject
      end

      context "when it is a destroy event" do
        let!(:meta) { { "model" => "Rdv", "event" => "destroyed" }.deep_symbolize_keys }

        it "enqueues a delete job" do
          expect(DeleteRdvJob).to receive(:perform_async)
            .with(rdv_solidarites_rdv_id)
          subject
        end
      end
    end

    context "when applicants should be notified" do
      it "calls the notify applicant job" do
        expect(NotifyApplicantJob).to receive(:perform_async)
          .with(applicant.id, organisation.id, data, "created")
        expect(NotifyApplicantJob).to receive(:perform_async)
          .with(applicant2.id, organisation.id, data, "created")
        subject
      end
    end

    context "when applicants should not be notified" do
      context "when the organisation does not notify applicants" do
        let!(:configuration) { create(:configuration, notify_applicant: false) }

        it "does not call the notify applicant job" do
          expect(NotifyApplicantJob).not_to receive(:perform_async)
          subject
        end
      end

      context "when the event is an update" do
        let!(:meta) do
          {
            "model" => "Absence",
            "event" => "updated"
          }.deep_symbolize_keys
        end

        it "does not call the notify applicant job" do
          expect(NotifyApplicantJob).not_to receive(:perform_async)
          subject
        end
      end
    end

    context "with an invalid category" do
      let!(:motif_attributes) { { id: 53, location: "public_office", category: nil } }

      it "does not call any job" do
        [UpsertRecordJob, DeleteRdvJob, NotifyApplicantJob].each do |klass|
          expect(klass).not_to receive(:perform_async)
        end
        subject
      end
    end

    context "with no matching configuration" do
      let!(:motif_attributes) { { id: 53, location: "public_office", category: "rsa_accompagnement" } }

      it "does not call any job" do
        [UpsertRecordJob, DeleteRdvJob, NotifyApplicantJob].each do |klass|
          expect(klass).not_to receive(:perform_async)
        end
        subject
      end
    end

    context "when the lieu in db does not match the lieu in webhook" do
      let!(:lieu) do
        create(
          :lieu, rdv_solidarites_lieu_id: rdv_solidarites_lieu_id, name: "DINUM", address: "15 avenue de Ségur",
                 organisation: organisation
        )
      end

      it "raises an error" do
        expect { subject }.to raise_error(
          WebhookProcessingJobError, "Lieu in webhook is not the same as the one in db: #{lieu_attributes}"
        )
      end
    end

    context "when there are webhook endpoints associated to the org" do
      let!(:webhook_endpoint) do
        create(:webhook_endpoint, organisations: [organisation])
      end
      let!(:department_internal_id) { "some-dept-id" }
      let!(:applicant) do
        create(
          :applicant,
          organisations: [organisation],
          id: 3,
          title: "monsieur",
          rdv_solidarites_user_id: user_id,
          department_internal_id: department_internal_id
        )
      end

      let!(:webhook_payload) do
        {
          data: data.merge(
            users: [{ id: user_id, department_internal_id: department_internal_id, title: "monsieur" }]
          ),
          meta: meta
        }
      end

      before do
        allow(Applicant).to receive(:find_by).with(rdv_solidarites_user_id: user_id).and_return(applicant)
      end

      it "enqueues a webhook job with an augmented payload" do
        expect(SendRdvSolidaritesWebhookJob).to receive(:perform_async)
          .with(webhook_endpoint.id, webhook_payload)
        subject
      end
    end
  end
end
