describe Invitations::Create, type: :service do
  subject do
    described_class.call(
      applicant: applicant, organisation: organisation,
      rdv_solidarites_session: rdv_solidarites_session,
      invitation_format: invitation_format
    )
  end

  let!(:invitation_format) { "sms" }
  let!(:rdv_solidarites_user_id) { 14 }
  let!(:organisation) { create(:organisation) }
  let!(:applicant) do
    create(:applicant, organisations: [organisation], rdv_solidarites_user_id: rdv_solidarites_user_id)
  end
  let!(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end
  let!(:token) { "token123" }
  let!(:invitation) { create(:invitation, organisation: organisation, applicant: applicant, token: token) }

  describe "#call" do
    let!(:invitation_link) { "https://www.rdv_solidarites.com/some_params" }

    before do
      allow(Invitations::RetrieveToken).to receive(:call)
        .and_return(OpenStruct.new(success?: true, invitation_token: token))
      allow(Invitations::ComputeLink).to receive(:call)
        .and_return(OpenStruct.new(success?: true, invitation_link: invitation_link))
      allow(Invitation).to receive(:new).and_return(invitation)
      allow(invitation).to receive(:save).and_return(true)
    end

    it "is a success" do
      is_a_success
    end

    it "creates an invitation" do
      expect(Invitation).to receive(:new)
        .with(
          applicant: applicant, organisation: organisation,
          link: invitation_link, token: token, format: invitation_format
        )
      expect(invitation).to receive(:save)
      subject
    end

    it "returns an invitation" do
      expect(subject.invitation).to eq(invitation)
    end

    context "retrieves an invitation token" do
      context "when there is no invitation for the applicant" do
        before do
          allow(applicant).to receive(:invitations)
            .and_return([])
        end

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
            expect(Invitation).not_to receive(:new)
            expect(invitation).not_to receive(:save)
            subject
          end
        end
      end

      context "when there is an invitation for the applicant" do
        before do
          allow(applicant).to receive(:invitations)
            .and_return([invitation])
        end

        it "does not try to retrieve an invitation token" do
          expect(Invitations::RetrieveToken).not_to receive(:call)
          subject
        end
      end
    end

    context "compute invitation link" do
      context "when there is no invitation for the applicant" do
        before do
          allow(applicant).to receive(:invitations)
            .and_return([])
        end

        it "tries to compute the invitation link" do
          expect(Invitations::ComputeLink).to receive(:call)
            .with(
              rdv_solidarites_session: rdv_solidarites_session,
              invitation_token: token,
              organisation: organisation
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
            expect(Invitation).not_to receive(:new)
            expect(invitation).not_to receive(:save)
            subject
          end
        end
      end

      context "when there is an invitation for the applicant" do
        before do
          allow(applicant).to receive(:invitations)
            .and_return([invitation])
        end

        it "does not try to compute the invitation link" do
          expect(Invitations::ComputeLink).not_to receive(:call)
          subject
        end
      end
    end

    context "invitation creation" do
      context "when there is no invitation for the applicant" do
        it "creates the invitation with the link and token" do
          expect(Invitation).to receive(:new)
            .with(
              applicant: applicant, organisation: organisation, format: invitation_format,
              token: token, link: invitation_link
            )
          expect(invitation).to receive(:save)
          subject
        end

        context "when it fails" do
          before do
            allow(invitation).to receive(:save)
              .and_return(false)
            allow(invitation).to receive_message_chain(:errors, :full_messages, :to_sentence)
              .and_return("Validation failed")
          end

          it "is a failure" do
            is_a_failure
          end

          it "stores the error" do
            expect(subject.errors).to eq(["Validation failed"])
          end
        end
      end

      context "when there is an invitation for the applicant" do
        before do
          allow(applicant).to receive(:invitations)
            .and_return([invitation])
        end

        it "does not try to retrieve an invitation token" do
          expect(Invitations::RetrieveToken).not_to receive(:call)
          subject
        end
      end
    end
  end
end
