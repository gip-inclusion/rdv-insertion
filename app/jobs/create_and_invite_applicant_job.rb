class CreateAndInviteApplicantJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(organisation_id, applicant_attributes, invitation_params, rdv_solidarites_session_credentials)
    @organisation = Organisation.find(organisation_id)
    @department = @organisation.department
    @applicant_attributes = applicant_attributes.deep_symbolize_keys
    @invitation_params = invitation_params.deep_symbolize_keys
    @rdv_solidarites_session_credentials = rdv_solidarites_session_credentials.deep_symbolize_keys

    assign_attributes_to_applicant
    return notify_creation_error if save_applicant.failure?

    invite_applicant
  end

  private

  def assign_attributes_to_applicant
    applicant.assign_attributes(
      department: @department,
      organisations: (applicant.organisations.to_a + [@organisation]).uniq,
      **@applicant_attributes
    )
  end

  def applicant
    @applicant ||= \
      FindOrInitializeApplicant.call(
        affiliation_number: @applicant_attributes[:affiliation_number],
        role: @applicant_attributes[:role],
        department_internal_id: @applicant_attributes[:department_internal_id],
        department_id: @department.id
      ).applicant
  end

  def invite_applicant
    enqueue_invite_job("sms") if @applicant_attributes[:phone_number].present?
    enqueue_invite_job("email") if @applicant_attributes[:email].present?
  end

  def enqueue_invite_job(invitation_format)
    InviteApplicantJob.perform_async(
      applicant.id,
      @organisation.id,
      @invitation_params.except(:context).merge(
        format: invitation_format,
        help_phone_number: @organisation.phone_number
      ),
      invitation_context,
      @rdv_solidarites_session_credentials
    )
  end

  def invitation_context
    # If not specified we invite on the first context found for the org
    @invitation_params[:context] || @organisation.configurations.first.context
  end

  def save_applicant
    @save_applicant ||= SaveApplicant.call(
      applicant: applicant,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def notify_creation_error
    notify_department_by_email(save_applicant.errors)
    capture_exception(save_applicant.errors)
  end

  def capture_exception(errors)
    Sentry.capture_exception(
      FailedServiceError.new("Error saving applicant in CreateAndInviteApplicantJob"),
      extra: {
        applicant: applicant,
        service_errors: errors,
        organisation: @organisation
      }
    )
  end

  def notify_department_by_email(errors)
    DepartmentMailer.create_applicant_error(@department, applicant, errors).deliver_now
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= RdvSolidaritesSession.new(**@rdv_solidarites_session_credentials)
  end
end
