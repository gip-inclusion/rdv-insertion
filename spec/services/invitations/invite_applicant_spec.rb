describe Invitations::InviteApplicant, type: :service do
  subject do
    described_class.call(
      applicant: applicant, rdv_solidarites_session: rdv_solidarites_session,
      invitation_format: invitation_format
    )
  end

  let!(:invitation_format) { "sms" }
  let!(:rdv_solidarites_user_id) { 14 }
  let!(:department) { create(:department) }
  let!(:applicant) { create(:applicant, department: department, rdv_solidarites_user_id: rdv_solidarites_user_id) }
  let!(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end
  let!(:invitation) { create(:invitation, applicant: applicant) }

  describe "#call" do
    let!(:token) { "token123" }
    let!(:invitation_link) { "https://www.rdv_solidarites.com/some_params" }
    let!(:rdv_solidarites_user) { instance_double(RdvSolidaritesUser) }

    before do
      allow(Invitations::RetrieveToken).to receive(:call)
        .and_return(OpenStruct.new(success?: true, invitation_token: token))
      allow(Invitations::ComputeLink).to receive(:call)
        .and_return(OpenStruct.new(success?: true, invitation_link: invitation_link))
      allow(Invitation).to receive(:new).and_return(invitation)
      allow(invitation).to receive(:save).and_return(true)
      allow(invitation).to receive(:send_to_applicant)
        .and_return(OpenStruct.new(success?: true))
    end

    it "is a success" do
      is_a_success
    end

    it "creates an invitation" do
      expect(Invitation).to receive(:new)
      expect(invitation).to receive(:save)
      subject
    end

    it "returns the invitation" do
      expect(subject.invitations.first).to eq(invitation)
    end

    context "retrieves an invitation token" do
      it "tries to retrieve an invitation token" do
        expect(Invitations::RetrieveToken).to receive(:call)
          .with(
            rdv_solidarites_session: rdv_solidarites_session,
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        subject
      end

      context "when it fails" do
        before do
          allow(Invitations::RetrieveToken).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
        end

        it "is a failure" do
          is_a_failure
        end

        it "stores the error" do
          expect(subject.errors).to eq(["something happened"])
        end

        it "does not create an invitation" do
          expect { subject }.to change(Invitation, :count).by(0)
        end
      end
    end

    context "compute invitation link" do
      it "tries to compute the invitation link" do
        expect(Invitations::ComputeLink).to receive(:call)
          .with(
            rdv_solidarites_session: rdv_solidarites_session,
            invitation_token: token,
            department: department
          )
        subject
      end

      context "when it fails" do
        before do
          allow(Invitations::ComputeLink).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
        end

        it "is a failure" do
          is_a_failure
        end

        it "stores the error" do
          expect(subject.errors).to eq(["something happened"])
        end

        it "does not create an invitation" do
          expect { subject }.to change(Invitation, :count).by(0)
        end
      end
    end

    context "invitation creation" do
      it "creates the invitation with the link and token" do
        expect(Invitation).to receive(:new)
          .with(
            applicant: applicant, format: invitation_format,
            token: token, link: invitation_link
          )
        expect(invitation).to receive(:save)
        subject
      end
    end

    context "sends invitation" do
      it "tries to send the invitation" do
        expect(invitation).to receive(:send_to_applicant)
        subject
      end

      context "when it fails" do
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
          expect(invitation).not_to receive(:update)
          expect(invitation.sent_at).to be_nil
          subject
        end
      end
    end

    context "mark as sent" do
      let!(:time_it_was_sent) { Time.zone.now }

      before do
        allow(Time.zone).to receive(:now).and_return(time_it_was_sent)
      end

      it "tries to timestamps the time the invitation got sent" do
        expect(invitation).to receive(:update).with(sent_at: time_it_was_sent)
        subject
      end

      context "when it fails" do
        before do
          allow(invitation).to receive(:save)
          allow(invitation).to receive(:update)
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
end
