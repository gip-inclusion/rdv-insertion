describe Notifications::NotifyApplicant, type: :service do
  subject do
    described_class.call(
      applicant: applicant, rdv: rdv, event: event, format: format
    )
  end

  let!(:applicant) { create(:applicant) }
  let!(:event) { "rdv_created" }
  let!(:rdv) { create(:rdv) }
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
      expect(notification.rdv_id).to eq(rdv.id)
      expect(notification.applicant_id).to eq(applicant.id)
      expect(notification.format).to eq(format)
      expect(notification.event).to eq(event)
      expect(notification.rdv_solidarites_rdv_id).to eq(rdv.rdv_solidarites_rdv_id)
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
  end
end
