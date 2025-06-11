class CreateUserJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(organisation_id, user_attributes)
    @organisation = Organisation.find(organisation_id)
    @department = @organisation.department
    @user_attributes = user_attributes.deep_symbolize_keys

    upsert_user!
  end

  private

  def upsert_user!
    upsert_user = Users::Upsert.call(
      user_attributes: @user_attributes,
      organisation: @organisation
    )
    @user = upsert_user.user
    return if upsert_user.success?

    notify_department_by_email(upsert_user.errors)
    raise(
      ApplicationJob::FailedServiceError,
      "Error upserting user in CreateUserJob: #{upsert_user.errors}"
    )
  end

  def notify_department_by_email(errors)
    DepartmentMailer.create_user_error(@department, @user_attributes, errors).deliver_now
  end
end
