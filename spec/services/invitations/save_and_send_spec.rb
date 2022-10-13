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
      allow(Invitations::AssignAttributes).to receive(:call)
        .with(invitation: invitation, rdv_solidarites_session: rdv_solidarites_session)
        .and_return(OpenStruct.new(success?: true))
      allow(invitation).to receive(:send_to_applicant)
        .and_return(OpenStruct.new(success?: true))
      allow(invitation).to receive(:rdv_solidarites_token?).and_return(false)
      allow(invitation).to receive(:link?).and_return(false)
    end

    it "is a success" do
      is_a_success
    end

    it "returns an invitation" do
      expect(subject.invitation).to eq(invitation)
    end

    it "saves an invitation" do
      expect(Invitations::AssignAttributes).to receive(:call)
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
        allow(Invitations::AssignAttributes).to receive(:call)
          .with(invitation: invitation, rdv_solidarites_session: rdv_solidarites_session)
          .and_return(OpenStruct.new(success?: false, errors: ["cannot assign token"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["cannot assign token"])
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

    context "when there is a token and a link assigned already" do
      before do
        allow(invitation).to receive(:rdv_solidarites_token?).and_return(true)
        allow(invitation).to receive(:link?).and_return(true)
      end

      it("is a success") { is_a_success }

      it "does not call the assign link and token service" do
        expect(Invitations::AssignAttributes).not_to receive(:call)
        subject
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
