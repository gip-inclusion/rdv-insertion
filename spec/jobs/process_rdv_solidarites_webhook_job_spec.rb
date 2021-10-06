describe ProcessRdvSolidaritesWebhookJob, type: :job do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:user_id) { 42 }
  let!(:user_ids) { [user_id] }
  let!(:rdv_solidarites_rdv_id) { 22 }
  let!(:organisation_id) { 52 }
  let!(:lieu) { { name: "DINUM", lieu: "20 avenue de Ségur" } }
  let!(:motif) { { location: "public_office" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }
  let!(:data) do
    {
      "id" => rdv_solidarites_rdv_id,
      "starts_at" => starts_at,
      "lieu" => lieu,
      "motif" => motif,
      "users" => [{ id: user_id }],
      "organisation" => { id: organisation_id }
    }.deep_symbolize_keys
  end

  let!(:meta) do
    {
      "model" => "Rdv",
      "event" => "created"
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_rdv) { OpenStruct.new(id: rdv_solidarites_rdv_id, user_ids: user_ids) }

  let!(:applicant) { create(:applicant, department: department, id: 3) }
  let!(:applicant2) { create(:applicant, department: department, id: 4) }

  let!(:configuration) { create(:configuration, department: department, notify_applicant: true) }
  let!(:department) { create(:department, rdv_solidarites_organisation_id: organisation_id) }

  describe "#perform" do
    before do
      allow(RdvSolidarites::Rdv).to receive(:new)
        .with(data)
        .and_return(rdv_solidarites_rdv)
      allow(Department).to receive(:find_by)
        .with(rdv_solidarites_organisation_id: 52)
        .and_return(department)
      allow(Applicant).to receive(:includes).and_return(Applicant)
      allow(Applicant).to receive(:where)
        .with(rdv_solidarites_user_id: user_ids)
        .and_return([applicant, applicant2])
      allow(UpsertRdvJob).to receive(:perform_async)
      allow(DeleteRdvJob).to receive(:perform_async)
      allow(NotifyApplicantJob).to receive(:perform_async)
      allow(MattermostClient).to receive(:send_to_notif_channel)
    end

    context "when no department is found" do
      let!(:department) { create(:department, id: 111) }

      before do
        allow(Department).to receive(:find_by)
          .with(rdv_solidarites_organisation_id: 52)
          .and_return(nil)
      end

      it "raises an error" do
        expect { subject }.to raise_error(WebhookProcessingJobError, "Department not found for organisation id 52")
      end
    end

    context "when no applicant is found" do
      before do
        allow(Applicant).to receive(:where)
          .with(rdv_solidarites_user_id: user_ids)
          .and_return([])
      end

      it "does not call the other jobs" do
        [UpsertRdvJob, DeleteRdvJob, NotifyApplicantJob].each do |klass|
          expect(klass).not_to receive(:perform_async)
        end
        subject
      end

      it "sends a message to mattermost" do
        expect(MattermostClient).to receive(:send_to_notif_channel)
        subject
      end
    end

    context "when there is a mismatch between one applicant and the department" do
      let!(:another_department) { create(:department) }
      let!(:applicant) { create(:applicant, id: 242, department: another_department) }

      it "raises an error" do
        expect { subject }.to raise_error(
          WebhookProcessingJobError,
          "Applicants / Department mismatch: applicant_ids: [242, 4] - department_id #{department.id} - "\
          "data: #{data} - meta: #{meta}"
        )
      end
    end

    context "it udpates the rdv" do
      it "enqueues an upsert job" do
        expect(UpsertRdvJob).to receive(:perform_async)
          .with(data, [applicant.id, applicant2.id], department.id)
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
      context "when the department does not notify applicants" do
        let!(:configuration) { create(:configuration, department: department, notify_applicant: false) }

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
        allow(Department).to receive(:find_by).and_return(department)
      end

      it "calls the notify applicant job" do
        expect(NotifyApplicantJob).to receive(:perform_async)
          .with(applicant.id, data, "created")
        expect(NotifyApplicantJob).to receive(:perform_async)
          .with(applicant2.id, data, "created")
        subject
      end
    end
  end
end
