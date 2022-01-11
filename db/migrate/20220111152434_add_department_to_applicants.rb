class AddDepartmentToApplicants < ActiveRecord::Migration[6.1]
  def change
    add_reference :applicants, :department, foreign_key: true

    up_only do
      Applicant.includes(organisations: [:department]).find_each do |applicant|
        next if applicant.organisations.blank?

        applicant.department_id = applicant.organisations.first.department.id
        applicant.save!
      end
    end
  end
end
