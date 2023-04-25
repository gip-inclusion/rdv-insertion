class RemoveDepartmentFromApplicants < ActiveRecord::Migration[7.0]
  def up
    remove_reference :applicants, :department
  end

  def down
    add_reference :applicants, :department, foreign_key: true
    Applicant.includes(:organisations).find_each do |applicant|
      applicant.department_id = applicant.organisations.first&.id
    end
  end
end
