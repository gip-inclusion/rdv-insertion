class CreateArchivings < ActiveRecord::Migration[7.0]
  def up
    create_table :archivings do |t|
      t.references :department, null: false, foreign_key: true
      t.references :applicant, null: false, foreign_key: true
      t.string :archiving_reason

      t.timestamps
    end

    Applicant.where.not(archived_at: nil).find_each do |applicant|
      archiving = ::Archiving.new(
        applicant_id: applicant.id,
        department_id: applicant.organisations.first.department_id,
        archiving_reason: applicant.archiving_reason,
        created_at: applicant.archived_at
      )
      archiving.save!
    end

    remove_column :applicants, :archived_at
    remove_column :applicants, :archiving_reason
  end

  def down
    add_column :applicants, :archived_at, :datetime
    add_column :applicants, :archiving_reason, :string

    Archiving.find_each do |archiving|
      applicant = archiving.applicant
      applicant.update!(
        archived_at: archiving.created_at,
        archiving_reason: archiving.archiving_reason
      )
    end

    drop_table :archivings
  end
end
