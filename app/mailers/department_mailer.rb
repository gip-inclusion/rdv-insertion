class DepartmentMailer < ApplicationMailer
  def create_applicant_error(department, applicant, errors)
    return if department.email.blank?

    @department = department
    @applicant = applicant
    @errors = errors
    mail(
      to: @department.email,
      subject: "Erreur en créant l'allocataire - ID #{@applicant.department_internal_id}"
    )
  end
end
