describe Notifications::NotifyParticipation, type: :service do
  subject do
    described_class.call(
      participation: participation, event: event, format: format
    )
  end

  let!(:participation) { create(:participation, rdv: rdv) }
  let!(:rdv_solidarites_rdv_id) { 444 }
  let!(:rdv) { create(:rdv, rdv_solidarites_rdv_id: rdv_solidarites_rdv_id, starts_at: 2.days.from_now) }
  let!(:event) { "participation_created" }
  let!(:format) { "sms" }

  describe "#call" do
    before do
      allow(Notifications::SendSms).to receive(:call).and_return(OpenStruct.new(success?: true))
    end

    it("is a success") { is_a_success }

    it "saves a notification" do
      expect { subject }.to change(Notification, :count).by(1)
    end

    it "sends the notification" do
      expect(Notifications::SendSms).to receive(:call)
      subject
    end

    it "assigns the attributes to the notification and mark it as sent" do
      subject
      notification = Notification.last
      expect(notification.participation_id).to eq(participation.id)
      expect(notification.format).to eq(format)
      expect(notification.event).to eq(event)
      expect(notification.rdv_solidarites_rdv_id).to eq(rdv_solidarites_rdv_id)
      expect(notification.sent_at).not_to be_nil
    end

    context "when it fails to send the notification" do
      before do
        allow(Notifications::SendSms).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["cannot send notification"]))
      end

      it("is a failure") { is_a_failure }

      it "fails with an error" do
        expect(subject.errors).to eq(["cannot send notification"])
      end
    end

    context "when the rdv is in the past" do
      before { rdv.update! starts_at: 2.days.ago }

      it("is a success") { is_a_success }

      it "does not send a notification" do
        expect(Notifications::SendSms).not_to receive(:call)
        subject
      end
    end

    context "when it is a reminder of a cancelled participation" do
      let!(:event) { "participation_reminder" }

      before { participation.update! status: "revoked" }

      it("is a success") { is_a_success }

      it "does not send a notification" do
        expect(Notifications::SendSms).not_to receive(:call)
        subject
      end
    end
  end
end
