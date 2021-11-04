class AddDepartmentToInvitation < ActiveRecord::Migration[6.1]
  def change
    add_reference :invitations, :department, foreign_key: true
    up_only do
      Invitation.find_each do |invitation|
        department = invitation.applicant.departments.first
        next unless department

        invitation.update!(department_id: department.id)
      end
    end
  end
end
