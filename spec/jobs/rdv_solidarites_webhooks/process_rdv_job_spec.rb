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
  let!(:lieu) { { id: 43, name: "DINUM", lieu: "20 avenue de Ségur" } }
  let!(:motif) { { id: 53, location: "public_office" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }
  let!(:data) do
    {
      "id" => rdv_solidarites_rdv_id,
      "starts_at" => starts_at,
      "address" => "20 avenue de segur",
      "context" => "all good",
      "lieu" => lieu,
      "motif" => motif,
      "users" => [{ id: user_id }],
      "organisation" => { id: rdv_solidarites_organisation_id }
    }.deep_symbolize_keys
  end

  let!(:meta) do
    {
      "model" => "Rdv",
      "event" => "created"
    }.deep_symbolize_keys
  end

  let!(:applicant) { create(:applicant, organisations: [organisation], id: 3) }
  let!(:applicant2) { create(:applicant, organisations: [organisation], id: 4) }

  let!(:configuration) { create(:configuration, notify_applicant: true, context: "rsa_orientation") }
  let!(:organisation) do
    create(
      :organisation,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id, configurations: [configuration]
    )
  end
  let!(:rdv_context) do
    build(:rdv_context, context: "rsa_orientation", applicant: applicant, id: 28)
  end

  let!(:rdv_context2) do
    build(:rdv_context, context: "rsa_orientation", applicant: applicant2, id: 99)
  end

  describe "#perform" do
    before do
      allow(Organisation).to receive(:find_by)
        .with(rdv_solidarites_organisation_id: 52)
        .and_return(organisation)
      allow(Applicant).to receive(:includes).and_return(Applicant)
      allow(Applicant).to receive(:where)
        .with(rdv_solidarites_user_id: user_ids)
        .and_return([applicant, applicant2])
      allow(RdvContext).to receive(:find_or_create_by!)
        .with(applicant: applicant, context: "rsa_orientation")
        .and_return(rdv_context)
      allow(RdvContext).to receive(:find_or_create_by!)
        .with(applicant: applicant2, context: "rsa_orientation")
        .and_return(rdv_context2)
      allow(UpsertRecordJob).to receive(:perform_async)
      allow(DeleteRdvJob).to receive(:perform_async)
      allow(NotifyApplicantJob).to receive(:perform_async)
      allow(MattermostClient).to receive(:send_to_notif_channel)
    end

    context "when no organisation is found" do
      let!(:organisation) { create(:organisation, id: 111) }

      before do
        allow(Organisation).to receive(:find_by)
          .with(rdv_solidarites_organisation_id: 52)
          .and_return(nil)
      end

      it "raises an error" do
        expect { subject }.to raise_error(WebhookProcessingJobError, "Organisation not found for organisation id 52")
      end
    end

    context "when no applicant is found" do
      before do
        allow(Applicant).to receive(:where)
          .with(rdv_solidarites_user_id: user_ids)
          .and_return([])
      end

      it "does not call the other jobs" do
        [UpsertRecordJob, DeleteRdvJob, NotifyApplicantJob].each do |klass|
          expect(klass).not_to receive(:perform_async)
        end
        subject
      end
    end

    context "it udpates the rdv" do
      let!(:rdv_attributes) do
        data.merge(
          rdv_solidarites_motif_id: rdv_solidarites_motif_id,
          rdv_solidarites_lieu_id: rdv_solidarites_lieu_id
        )
      end

      it "enqueues an upsert job" do
        expect(UpsertRecordJob).to receive(:perform_async)
          .with(
            "Rdv",
            rdv_attributes,
            {
              applicant_ids: [applicant.id, applicant2.id],
              organisation_id: organisation.id,
              rdv_context_ids: [rdv_context.id, rdv_context2.id]
            }
          )
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

    context "when applicants should be notified" do
      before do
        allow(Organisation).to receive(:find_by).and_return(organisation)
      end

      it "calls the notify applicant job" do
        expect(NotifyApplicantJob).to receive(:perform_async)
          .with(applicant.id, organisation.id, data, "created")
        expect(NotifyApplicantJob).to receive(:perform_async)
          .with(applicant2.id, organisation.id, data, "created")
        subject
      end
    end
  end
end
