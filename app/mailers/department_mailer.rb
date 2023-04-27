class DepartmentMailer < ApplicationMailer
  def create_applicant_error(department, applicant_attributes, errors)
    return if department.email.blank?

    @department = department
    @applicant_attributes = applicant_attributes.deep_symbolize_keys
    @errors = errors
    mail(
      to: @department.email,
      subject: "Erreur en créant un allocataire#{department_internal_id_in_subject}"
    )
  end

  private

  def department_internal_id_in_subject
    @applicant_attributes[:department_internal_id] ? " - ID #{@applicant_attributes[:department_internal_id]}" : ""
  end
end
