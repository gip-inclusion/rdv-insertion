class CreateArchives < ActiveRecord::Migration[7.0]
  def up
    create_table :archives do |t|
      t.references :department, null: false, foreign_key: true
      t.references :applicant, null: false, foreign_key: true
      t.string :archiving_reason

      t.timestamps
    end

    Applicant.where.not(archived_at: nil).find_each do |applicant|
      archive = ::Archive.new(
        applicant_id: applicant.id,
        department_id: applicant.organisations.first.department_id,
        archiving_reason: applicant.archiving_reason,
        created_at: applicant.archived_at
      )
      archive.save!
    end

    remove_column :applicants, :archived_at
    remove_column :applicants, :archiving_reason
  end

  def down
    add_column :applicants, :archived_at, :datetime
    add_column :applicants, :archiving_reason, :string

    Archive.find_each do |archive|
      applicant = archive.applicant
      applicant.update!(
        archived_at: archive.created_at,
        archiving_reason: archive.archiving_reason
      )
    end

    drop_table :archives
  end
end
