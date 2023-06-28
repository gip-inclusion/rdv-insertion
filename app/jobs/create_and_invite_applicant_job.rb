class CreateAndInviteApplicantJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(organisation_id, applicant_attributes, invitation_params, rdv_solidarites_session_credentials)
    @organisation = Organisation.find(organisation_id)
    @department = @organisation.department
    @applicant_attributes = applicant_attributes.deep_symbolize_keys
    @invitation_params = invitation_params.deep_symbolize_keys
    @rdv_solidarites_session_credentials = rdv_solidarites_session_credentials.deep_symbolize_keys

    find_or_initialize_applicant!
    applicant.assign_attributes(**@applicant_attributes)
    save_applicant!
    invite_applicant
  end

  private

  def applicant
    @applicant ||= find_or_initialize_applicant.applicant
  end

  def find_or_initialize_applicant!
    return if find_or_initialize_applicant.success?

    notify_department_by_email(find_or_initialize_applicant.errors)
    raise(
      FailedServiceError,
      "Error initializing applicant in CreateAndInviteApplicantJob: #{find_or_initialize_applicant.errors}"
    )
  end

  def find_or_initialize_applicant
    @find_or_initialize_applicant ||= Applicants::FindOrInitialize.call(
      attributes: @applicant_attributes,
      department_id: @department.id
    )
  end

  def invite_applicant
    enqueue_invite_job("sms") if applicant.phone_number_is_mobile?
    enqueue_invite_job("email") if applicant.email.present?
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

  def save_applicant!
    return if save_applicant.success?

    notify_department_by_email(save_applicant.errors)
    raise FailedServiceError, "Error saving applicant in CreateAndInviteApplicantJob: #{save_applicant.errors}"
  end

  def save_applicant
    @save_applicant ||= Applicants::Save.call(
      applicant: applicant,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def notify_department_by_email(errors)
    DepartmentMailer.create_applicant_error(@department, @applicant_attributes, errors).deliver_now
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= RdvSolidaritesSessionFactory.create_with(**@rdv_solidarites_session_credentials)
  end
end
