describe CreateAndInviteApplicantJob, type: :job do
  subject do
    described_class.new.perform(
      organisation_id, applicant_attributes, invitation_attributes, rdv_solidarites_session_credentials
    )
  end

  let!(:organisation_id) { 99 }
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department, id: organisation_id, phone_number: "0146292929") }
  let!(:applicant) { create(:applicant) }
  let!(:applicant_attributes) do
    { department_internal_id: "1919", affiliation_number: "00001", role: "conjoint", phone_number: "07070707",
      email: "john.doe@apijob.com" }
  end
  let!(:invitation_attributes) { { rdv_solidarites_lieu_id: 888 } }
  let!(:sms_invitation_attributes) do
    invitation_attributes.merge(help_phone_number: "0146292929", context: "RSA orientation", format: "sms")
  end
  let!(:email_invitation_attributes) do
    invitation_attributes.merge(help_phone_number: "0146292929", context: "RSA orientation", format: "email")
  end
  let!(:rdv_solidarites_session_credentials) { session_hash.symbolize_keys }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }

  before do
    allow(Applicant).to receive(:new).and_return(applicant)
    allow(SaveApplicant).to receive(:call).and_return(OpenStruct.new(success?: true, failure?: false))
    allow(RdvSolidaritesSession).to receive(:new)
      .with(rdv_solidarites_session_credentials)
      .and_return(rdv_solidarites_session)
    allow(InviteApplicantJob).to receive(:perform_async)
  end

  it "assigns the attributes to the applicant" do
    expect(applicant).to receive(:assign_attributes)
      .with(applicant_attributes.merge(department: department, organisations: [organisation]))
    subject
  end

  it "saves the applicant" do
    expect(SaveApplicant).to receive(:call)
      .with(applicant: applicant, organisation: organisation, rdv_solidarites_session: rdv_solidarites_session)
    subject
  end

  it "enqueues invite applicant jobs" do
    expect(InviteApplicantJob).to receive(:perform_async)
      .with(applicant.id, organisation.id, sms_invitation_attributes, rdv_solidarites_session_credentials)
    expect(InviteApplicantJob).to receive(:perform_async)
      .with(applicant.id, organisation.id, email_invitation_attributes, rdv_solidarites_session_credentials)
    subject
  end

  context "when the applicant already exists" do
    context "from department internal id" do
      let!(:applicant) { create(:applicant, organisations: [organisation], department_internal_id: "1919") }

      before do
        allow(Applicant).to receive(:find_by).with(department_internal_id: "1919").and_return(applicant)
      end

      it "does not instantiate a new appicant" do
        expect(Applicant).not_to receive(:new)
        subject
      end

      it "assigns the attributes" do
        expect(applicant).to receive(:assign_attributes)
          .with(applicant_attributes.merge(department: department, organisations: [organisation]))
        subject
      end

      it "saves the applicant" do
        expect(SaveApplicant).to receive(:call)
          .with(applicant: applicant, organisation: organisation, rdv_solidarites_session: rdv_solidarites_session)
        subject
      end

      it "enqueues invite applicant jobs" do
        expect(InviteApplicantJob).to receive(:perform_async)
          .with(applicant.id, organisation.id, sms_invitation_attributes, rdv_solidarites_session_credentials)
        expect(InviteApplicantJob).to receive(:perform_async)
          .with(applicant.id, organisation.id, email_invitation_attributes, rdv_solidarites_session_credentials)
        subject
      end
    end

    context "from affiliation_number and role" do
      let!(:applicant) do
        create(:applicant, organisations: [organisation], affiliation_number: "00001", role: "conjoint")
      end

      before do
        allow(Applicant).to receive(:find_by).with(department_internal_id: "1919").and_return(nil)
        allow(Applicant).to receive(:find_by).with(affiliation_number: "00001", role: "conjoint").and_return(applicant)
      end

      it "does not instantiate a new appicant" do
        expect(Applicant).not_to receive(:new)
        subject
      end

      it "assigns the attributes" do
        expect(applicant).to receive(:assign_attributes)
          .with(applicant_attributes.merge(department: department, organisations: [organisation]))
        subject
      end

      it "saves the applicant" do
        expect(SaveApplicant).to receive(:call)
          .with(applicant: applicant, organisation: organisation, rdv_solidarites_session: rdv_solidarites_session)
        subject
      end

      it "enqueues invite applicant jobs" do
        expect(InviteApplicantJob).to receive(:perform_async)
          .with(applicant.id, organisation.id, sms_invitation_attributes, rdv_solidarites_session_credentials)
        expect(InviteApplicantJob).to receive(:perform_async)
          .with(applicant.id, organisation.id, email_invitation_attributes, rdv_solidarites_session_credentials)
        subject
      end
    end

    context "when there is no phone" do
      before { applicant_attributes[:phone_number] = nil }

      it "does not enqueue an invite sms job" do
        expect(InviteApplicantJob).not_to receive(:perform_async)
          .with(applicant.id, organisation.id, sms_invitation_attributes, rdv_solidarites_session_credentials)
        subject
      end
    end

    context "when there is no email" do
      before { applicant_attributes[:email] = nil }

      it "does not enqueue an invite email job" do
        expect(InviteApplicantJob).not_to receive(:perform_async)
          .with(applicant.id, organisation.id,  email_invitation_attributes, rdv_solidarites_session_credentials)
        subject
      end
    end

    context "when the save fails" do
      let!(:department_mail) { instance_double("mail") }

      before do
        allow(SaveApplicant).to receive(:call)
          .and_return(OpenStruct.new(failure?: true, errors: ["could not save applicant"]))
        allow(Sentry).to receive(:capture_exception)
        allow(DepartmentMailer).to receive(:create_applicant_error).and_return(department_mail)
        allow(department_mail).to receive(:deliver_now)
      end

      it "captures the exception" do
        exception = FailedServiceError.new("Error saving applicant in CreateAndInviteApplicantJob")
        expect(Sentry).to receive(:capture_exception)
          .with(
            exception,
            extra: {
              applicant: applicant,
              service_errors: ["could not save applicant"],
              organisation: organisation
            }
          )
        subject
      end

      it "sends an email to the department" do
        expect(DepartmentMailer).to receive(:create_applicant_error)
          .with(department, applicant, ["could not save applicant"])
        expect(department_mail).to receive(:deliver_now)
        subject
      end
    end
  end
end
