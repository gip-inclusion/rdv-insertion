class DepartmentMailer < ApplicationMailer
  def create_user_error(department, user_attributes, errors)
    return if department.email.blank?

    @department = department
    @user_attributes = user_attributes.deep_symbolize_keys
    @errors = errors
    mail(
      to: @department.email,
      subject: "Erreur en créant un usager#{department_internal_id_in_subject}"
    )
  end

  private

  def department_internal_id_in_subject
    @user_attributes[:department_internal_id] ? " - ID #{@user_attributes[:department_internal_id]}" : ""
  end
end
