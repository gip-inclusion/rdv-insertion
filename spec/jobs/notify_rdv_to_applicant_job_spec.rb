describe NotifyRdvToApplicantJob, type: :job do
  subject do
    described_class.new.perform(rdv_id, applicant_id, format, event)
  end

  let!(:rdv_id) { 2323 }
  let!(:applicant_id) { 3232 }
  let!(:rdv) { create(:rdv, id: rdv_id) }
  let!(:applicant) { create(:applicant, id: applicant_id) }
  let!(:format) { "sms" }
  let!(:event) { "rdv_created" }

  describe "#perform" do
    before do
      allow(Notifications::NotifyApplicant).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
      allow(MattermostClient).to receive(:send_to_notif_channel)
    end

    it "calls the notify applicant service" do
      expect(Notifications::NotifyApplicant).to receive(:call)
        .with(rdv: rdv, applicant: applicant, format: format, event: event)
      subject
    end

    context "when the service fails" do
      before do
        allow(Notifications::NotifyApplicant).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["cannot notify"]))
      end

      it "raises an error" do
        expect { subject }.to raise_error(NotificationsJobError, "cannot notify")
      end
    end

    context "when the applicant has already been notified for this rdv" do
      let!(:notification) do
        create(:notification, rdv: rdv, applicant: applicant, event: event, sent_at: 2.days.ago)
      end

      it "does not calls the notify applicant service" do
        expect(Notifications::NotifyApplicant).not_to receive(:call)
        subject
      end

      it "sends a message to mattermost" do
        expect(MattermostClient).to receive(:send_to_notif_channel)
          .with(
            "Rdv already notified to applicant. Skipping notification sending.\n" \
            "rdv id: #{rdv.id}\n" \
            "applicant_id: #{applicant.id}\n" \
            "format: #{format}\n" \
            "event: #{event}"
          )
        subject
      end

      context "when the event is rdv_updated" do
        let!(:event) { "rdv_updated" }

        it "still calls the notify applicant service" do
          expect(Notifications::NotifyApplicant).to receive(:call)
            .with(rdv: rdv, applicant: applicant, format: format, event: event)
          subject
        end

        context "when there has been two sent notifications in the past hour" do
          let!(:notification) do
            create(:notification, rdv: rdv, applicant: applicant, event: event, sent_at: 40.minutes.ago)
          end
          let!(:notification2) do
            create(:notification, rdv: rdv, applicant: applicant, event: event, sent_at: 20.minutes.ago)
          end

          it "does not calls the notify applicant service" do
            expect(Notifications::NotifyApplicant).not_to receive(:call)
            subject
          end

          it "sends a message to mattermost" do
            expect(MattermostClient).to receive(:send_to_notif_channel)
              .with(
                "Rdv already notified to applicant. Skipping notification sending.\n" \
                "rdv id: #{rdv.id}\n" \
                "applicant_id: #{applicant.id}\n" \
                "format: #{format}\n" \
                "event: #{event}"
              )
            subject
          end
        end
      end
    end
  end
end
