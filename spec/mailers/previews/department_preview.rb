# Preview all emails at http://localhost:8000/rails/mailers/department
class DepartmentPreview < ActionMailer::Preview
  def create_user_error
    department = Department.joins(:users).first
    department.email = "contact@department.fr"

    user = department.users.first
    user.department_internal_id = "0212211"

    errors = ["Erreur RDV-Solidarités: Service indisponible"]

    DepartmentMailer.create_user_error(department, user, errors)
  end
end
