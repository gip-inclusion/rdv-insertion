class AddDepartmentApplicants < ActiveRecord::Migration[6.1]
  # from one-to-many to many-to-many
  def up
    create_join_table :departments, :applicants do |t|
      t.index [:department_id, :applicant_id], unique: true
    end

    Applicant.find_each do |applicant|
      applicant.update!(departments: [Department.find(applicant.department_id)]) unless applicant.department_id.nil?
    end

    remove_reference :applicants, :department, null: false, foreign_key: true
  end

  def down
    add_reference :applicants, :department, foreign_key: true

    Applicant.find_each do |applicant|
      applicant.update!(department_id: applicant.department_ids.first) unless applicant.department_ids.empty?
    end

    drop_join_table :departments, :applicants
  end
end
