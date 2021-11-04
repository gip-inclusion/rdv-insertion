class ChangeDepartmentTable < ActiveRecord::Migration[6.1]
  def up
    add_reference :organisations, :department, foreign_key: true

    Organisation.find_each do |organisation|
      department = Department.find_by(rdv_solidarites_organisation_id: organisation.rdv_solidarites_organisation_id)
      organisation.department_id = department.id
      organisation.save!
    end

    remove_column :departments, :rdv_solidarites_organisation_id
    remove_column :departments, :phone_number
    drop_table :applicants_departments
    drop_table :agents_departments
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def down
    create_join_table :departments, :agents do |t|
      t.index [:department_id, :agent_id], unique: true
    end

    create_join_table :departments, :applicants do |t|
      t.index [:department_id, :applicant_id], unique: true
    end

    add_column :departments, :rdv_solidarites_organisation_id, :bigint

    add_column :departments, :phone_number, :string

    Department.find_each do |department|
      organisation = Organisation.find_by(department_id: department.id)
      department.rdv_solidarites_organisation_id = organisation.rdv_solidarites_organisation_id
      department.phone_number = organisation.phone_number
      department.applicant_ids = organisation.applicant_ids
      department.agent_ids = organisation.agent_ids

      department.save!
    end

    remove_reference :organisations, :department, null: false, foreign_key: true
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
