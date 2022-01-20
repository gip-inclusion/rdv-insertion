describe Invitations::SaveAndSend, type: :service do
  subject do
    described_class.call(
      invitation: invitation, rdv_solidarites_session: rdv_solidarites_session
    )
  end

  let!(:applicant) { create(:applicant) }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let!(:invitation) { create(:invitation, applicant: applicant, sent_at: nil) }

  describe "#call" do
    before do
      allow(Invitations::SaveWithLink).to receive(:call)
        .with(invitation: invitation, rdv_solidarites_session: rdv_solidarites_session)
        .and_return(OpenStruct.new(success?: true))
      allow(invitation).to receive(:send_to_applicant)
        .and_return(OpenStruct.new(success?: true))
    end

    it "is a success" do
      is_a_success
    end

    it "returns an invitation" do
      expect(subject.invitation).to eq(invitation)
    end

    it "saves an invitation" do
      expect(Invitations::SaveWithLink).to receive(:call)
        .with(invitation: invitation, rdv_solidarites_session: rdv_solidarites_session)
      subject
    end

    it "sends the invitation" do
      expect(invitation).to receive(:send_to_applicant)
      subject
    end

    it "marks the invitation as sent" do
      subject
      expect(invitation.reload.sent_at).not_to be_nil
    end

    context "when it fails to save" do
      before do
        allow(Invitations::SaveWithLink).to receive(:call)
          .with(invitation: invitation, rdv_solidarites_session: rdv_solidarites_session)
          .and_return(OpenStruct.new(success?: false, errors: ["cannot save invitation"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["cannot save invitation"])
      end
    end

    context "when it fails to send invitation" do
      before do
        allow(invitation).to receive(:send_to_applicant)
          .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["something happened"])
      end

      it "does not mark the invitation as sent" do
        subject
        expect(invitation.sent_at).to be_nil
      end
    end

    context "when it fails to mark as sent" do
      before do
        allow(invitation).to receive(:save)
          .and_return(false)
        allow(invitation).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return('some error')
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(['some error'])
      end
    end
  end
end
