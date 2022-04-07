describe InviteApplicantJob, type: :job do
  subject do
    described_class.new.perform(
      applicant_id, organisation_id, invitation_attributes, rdv_solidarites_session_credentials
    )
  end

  let!(:applicant_id) { 9999 }
  let!(:organisation_id) { 999 }
  let!(:department) { create(:department) }
  let!(:applicant) { create(:applicant, id: applicant_id) }
  let!(:organisation) { create(:organisation, id: organisation_id, department: department) }
  let!(:rdv_solidarites_session_credentials) { session_hash.symbolize_keys }
  let!(:invitation_format) { "sms" }
  let!(:invitation_attributes) do
    { format: invitation_format, context: "RSA orientation",
      help_phone_number: "01010101", rdv_solidarites_lieu_id: 444 }
  end
  let!(:invitation) { create(:invitation) }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }

  describe "#perform" do
    context "when the applicant has not been invited yet" do
      before do
        allow(Invitation).to receive(:new).with(
          invitation_attributes.merge(
            applicant: applicant, department: department, organisations: [organisation]
          )
        ).and_return(invitation)
        allow(RdvSolidaritesSession).to receive(:new)
          .with(rdv_solidarites_session_credentials)
          .and_return(rdv_solidarites_session)
        allow(Invitations::SaveAndSend).to receive(:call)
          .with(invitation: invitation, rdv_solidarites_session: rdv_solidarites_session)
          .and_return(OpenStruct.new(failure?: false))
      end

      it "instantiates an invitation" do
        expect(Invitation).to receive(:new).with(
          invitation_attributes.merge(
            applicant: applicant, department: department, organisations: [organisation]
          )
        )
        subject
      end

      it "invites the applicant" do
        expect(Invitations::SaveAndSend).to receive(:call)
          .with(invitation: invitation, rdv_solidarites_session: rdv_solidarites_session)
        subject
      end

      context "when it fails to send it" do
        before do
          allow(Invitations::SaveAndSend).to receive(:call)
            .with(invitation: invitation, rdv_solidarites_session: rdv_solidarites_session)
            .and_return(OpenStruct.new(failure?: true, errors: ["Could not send invite"]))
          allow(Sentry).to receive(:capture_exception)
        end

        it "captures the expection" do
          exception = FailedServiceError.new("Save and send invitation error in InviteApplicantJob")
          expect(Sentry).to receive(:capture_exception)
            .with(
              exception,
              extra: {
                applicant: applicant,
                service_errors: ["Could not send invite"],
                organisation: organisation,
                invitation_attributes: invitation_attributes
              }
            )
          subject
        end
      end
    end

    context "when the applicant has already been invited in the last 24 hours" do
      let!(:other_invitation) do
        create(:invitation, applicant: applicant, format: invitation_format, sent_at: 3.hours.ago)
      end

      it "does not invite the applicant" do
        expect(Invitations::SaveAndSend).not_to receive(:call)
        subject
      end
    end
  end
end
