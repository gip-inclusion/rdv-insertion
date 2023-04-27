class CreateAndInviteApplicantJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(organisation_id, applicant_attributes, invitation_params, rdv_solidarites_session_credentials)
    @organisation = Organisation.find(organisation_id)
    @department = @organisation.department
    @applicant_attributes = applicant_attributes.deep_symbolize_keys
    @invitation_params = invitation_params.deep_symbolize_keys
    @rdv_solidarites_session_credentials = rdv_solidarites_session_credentials.deep_symbolize_keys

    return notify_creation_error(process_input.errors) if process_input.failure?

    applicant.assign_attributes(**@applicant_attributes)

    return notify_creation_error(save_applicant.errors) if save_applicant.failure?

    invite_applicant
  end

  private

  def applicant
    @applicant ||=
      process_input.matching_applicant || Applicant.new
  end

  def process_input
    @process_input ||= Applicants::ProcessInput.call(
      applicant_params: @applicant_attributes,
      department_id: @department.id
    )
  end

  def invite_applicant
    enqueue_invite_job("sms") if applicant.phone_number_is_mobile?
    enqueue_invite_job("email") if @applicant.email.present?
  end

  def enqueue_invite_job(invitation_format)
    InviteApplicantJob.perform_async(
      applicant.id,
      @organisation.id,
      @invitation_params.except(:motif_category_name).merge(
        format: invitation_format,
        help_phone_number: @organisation.phone_number
      ),
      invitation_motif_category.id,
      @rdv_solidarites_session_credentials
    )
  end

  def invitation_motif_category
    # If not specified we invite on the first motif category found for the org
    if @invitation_params[:motif_category_name].present?
      @organisation.motif_categories.find { |mc| mc.name == @invitation_params[:motif_category_name] }
    else
      @organisation.motif_categories.min_by(&:position)
    end
  end

  def save_applicant
    @save_applicant ||= Applicants::Save.call(
      applicant: applicant,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def notify_creation_error(errors)
    notify_department_by_email(errors)
    capture_exception(errors)
  end

  def capture_exception(errors)
    Sentry.capture_exception(
      FailedServiceError.new("Error saving applicant in CreateAndInviteApplicantJob"),
      extra: {
        applicant_attributes: @applicant_attributes,
        service_errors: errors,
        organisation: @organisation
      }
    )
  end

  def notify_department_by_email(errors)
    DepartmentMailer.create_applicant_error(@department, @applicant_attributes, errors).deliver_now
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= RdvSolidaritesSessionFactory.create_with(**@rdv_solidarites_session_credentials)
  end
end
