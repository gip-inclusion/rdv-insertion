# Preview all emails at http://localhost:8000/rails/mailers/department
class DepartmentPreview < ActionMailer::Preview
  def create_applicant_error
    department = Department.joins(:applicants).first
    department.email = "contact@department.fr"

    applicant = department.applicants.first
    applicant.department_internal_id = "0212211"

    errors = ["Erreur RDV-Solidarités: Service indisponible"]

    DepartmentMailer.create_applicant_error(department, applicant, errors)
  end
end
