class AddIsArchivedToApplicants < ActiveRecord::Migration[6.1]
  def up
    add_column :applicants, :is_archived, :boolean, default: false

    Applicant.find_each do |applicant|
      applicant.is_archived = true if Applicant.statuses[applicant.status] == 9
      applicant.status = 0 # right status will be automatically computed
      applicant.save!
    end
  end

  def down
    Applicant.find_each do |applicant|
      applicant.status = 9 if applicant.is_archived == true
      applicant.save!
    end

    remove_column :applicants, :is_archived
  end
end
