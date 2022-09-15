class AddArchivedAtToApplicants < ActiveRecord::Migration[7.0]
  def up
    add_column :applicants, :archived_at, :datetime
    Applicant.where(is_archived: true).find_each do |applicant|
      applicant.update!(archived_at: Time.zone.now)
    end
    remove_column :applicants, :is_archived
  end

  def down
    add_column :applicants, :is_archived, :boolean, default: false
    Applicant.where.not(archived_at: nil).find_each do |applicant|
      applicant.update!(is_archived: true)
    end
    remove_column :applicants, :archived_at
  end
end
