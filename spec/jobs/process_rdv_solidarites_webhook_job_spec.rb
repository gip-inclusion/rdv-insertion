describe ProcessRdvSolidaritesWebhookJob, type: :job do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:user_id) { 42 }
  let!(:organisation_id) { 52 }
  let!(:lieu) { { name: "DINUM", lieu: "20 avenue de Ségur" } }
  let!(:motif) { { location: "public_office" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }
  let!(:data) do
    {
      "starts_at" => starts_at,
      "lieu" => lieu,
      "motif" => motif,
      "users" => [{ id: user_id }],
      "organisation" => { id: organisation_id }
    }
  end

  let!(:meta) do
    {
      "model" => "Rdv",
      "event" => "created"
    }
  end

  let!(:applicant) { create(:applicant, department: department, rdv_solidarites_user_id: user_id, id: 3) }
  let!(:configuration) { create(:configuration, department: department, notify_applicant: true) }
  let!(:department) { create(:department, rdv_solidarites_organisation_id: organisation_id) }

  describe "#call" do
    context "when no department is found" do
      let!(:department) { create(:department, id: 111) }

      it "raises an error" do
        expect { subject }.to raise_error(WebhookProcessingJobError, "Department not found")
      end
    end

    context "when no applicant is found" do
      let!(:applicant) { create(:applicant, department: department, rdv_solidarites_user_id: 111) }

      it "raises an error" do
        expect { subject }.to raise_error(WebhookProcessingJobError, "Applicant not found")
      end
    end

    context "when there is a mismatch between the applicant and the department" do
      let!(:another_department) { create(:department) }
      let!(:applicant) { create(:applicant, department: another_department, rdv_solidarites_user_id: user_id) }

      it "raises an error" do
        expect { subject }.to raise_error(WebhookProcessingJobError, "Applicant / Department mismatch")
      end
    end

    context "when the applicant should not notified" do
      context "when the department does not notify applicants" do
        let!(:configuration) { create(:configuration, department: department, notify_applicant: false) }

        it "does not call the notify applicant job" do
          expect(NotifyApplicantJob).not_to receive(:perform_async)
          subject
        end
      end

      context "when the event is not linked to a rdv" do
        let!(:meta) do
          {
            "model" => "Absence",
            "event" => "created"
          }
        end

        it "does not call the notify applicant job" do
          expect(NotifyApplicantJob).not_to receive(:perform_async)
          subject
        end
      end
    end

    context "when the applicant should be notified" do
      before do
        allow(Department).to receive(:find_by).and_return(department)
      end

      it "calls the notify applicant job" do
        expect(NotifyApplicantJob).to receive(:perform_async)
          .with(3, lieu, motif, starts_at, "created")
        subject
      end
    end
  end
end
