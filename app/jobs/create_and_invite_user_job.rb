class CreateAndInviteUserJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(organisation_id, user_attributes, invitation_params, rdv_solidarites_session_credentials)
    @organisation = Organisation.find(organisation_id)
    @department = @organisation.department
    @user_attributes = user_attributes.deep_symbolize_keys
    @invitation_params = invitation_params.deep_symbolize_keys
    @rdv_solidarites_session_credentials = rdv_solidarites_session_credentials.deep_symbolize_keys

    find_or_initialize_user!
    user.assign_attributes(**@user_attributes)
    save_user!
    invite_user
  end

  private

  def user
    @user ||= find_or_initialize_user.user
  end

  def find_or_initialize_user!
    return if find_or_initialize_user.success?

    notify_department_by_email(find_or_initialize_user.errors)
    raise(
      FailedServiceError,
      "Error initializing user in CreateAndInviteUserJob: #{find_or_initialize_user.errors}"
    )
  end

  def find_or_initialize_user
    @find_or_initialize_user ||= Users::FindOrInitialize.call(
      attributes: @user_attributes,
      department_id: @department.id
    )
  end

  def invite_user
    enqueue_invite_job("sms") if user.phone_number_is_mobile?
    enqueue_invite_job("email") if user.email.present?
  end

  def enqueue_invite_job(invitation_format)
    InviteUserJob.perform_async(
      user.id,
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
      @organisation.configurations.order(position: :asc).first.motif_category
    end
  end

  def save_user!
    return if save_user.success?

    notify_department_by_email(save_user.errors)
    raise FailedServiceError, "Error saving user in CreateAndInviteUserJob: #{save_user.errors}"
  end

  def save_user
    @save_user ||= Users::Save.call(
      user: user,
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def notify_department_by_email(errors)
    DepartmentMailer.create_user_error(@department, @user_attributes, errors).deliver_now
  end

  def rdv_solidarites_session
    @rdv_solidarites_session ||= RdvSolidaritesSessionFactory.create_with(**@rdv_solidarites_session_credentials)
  end
end
