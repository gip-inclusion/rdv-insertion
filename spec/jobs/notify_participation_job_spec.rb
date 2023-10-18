describe NotifyParticipationJob do
  subject do
    described_class.new.perform(participation_id, format, event)
  end

  let!(:participation_id) { 3232 }
  let!(:participation) { create(:participation, id: participation_id, user:) }
  let!(:user) { create(:user) }
  let!(:format) { "sms" }
  let!(:event) { "participation_created" }

  describe "#perform" do
    before do
      allow(Notifications::NotifyParticipation).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    it "calls the notify user service" do
      expect(Notifications::NotifyParticipation).to receive(:call)
        .with(participation: participation, format: format, event: event)
      subject
    end

    context "when the service fails" do
      before do
        allow(Notifications::NotifyParticipation).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["cannot notify"]))
      end

      it "raises an error" do
        expect { subject }.to raise_error(NotificationsJobError, "cannot notify")
      end
    end

    context "when the user has already been notified for this rdv" do
      let!(:notification) do
        create(:notification, participation: participation, event: event, sent_at: 2.days.ago)
      end

      it "does not calls the notify user service" do
        expect(Notifications::NotifyParticipation).not_to receive(:call)
        subject
      end

      context "when the event is participation_updated" do
        let!(:event) { "participation_updated" }

        it "still calls the notify user service" do
          expect(Notifications::NotifyParticipation).to receive(:call)
            .with(participation: participation, format: format, event: event)
          subject
        end

        context "when there has been two sent notifications in the past hour" do
          let!(:notification) do
            create(:notification, participation: participation, event: event, sent_at: 40.minutes.ago)
          end
          let!(:notification2) do
            create(:notification, participation: participation, event: event, sent_at: 20.minutes.ago)
          end

          it "does not calls the notify user service" do
            expect(Notifications::NotifyParticipation).not_to receive(:call)
            subject
          end
        end
      end

      context "when the user is created through rdv_solidarites and has no invitations" do
        let!(:user) do
          create(:user, created_through: "rdv_solidarites", invitations: [])
        end

        it "does notify the user" do
          expect(Notifications::NotifyParticipation).not_to receive(:call)
          subject
        end
      end
    end
  end
end
