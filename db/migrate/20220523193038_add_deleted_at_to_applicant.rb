class AddDeletedAtToApplicant < ActiveRecord::Migration[7.0]
  def up
    add_column :applicants, :deleted_at, :datetime

    Applicant.where(status: 10).find_each do |applicant|
      applicant.update_columns deleted_at: Time.zone.now
    end
  end

  def down
    Applicant.where.not(deleted_at: nil).find_each do |applicant|
      applicant.update_columns status: 10
    end

    remove_column :applicants, :deleted_at, :datetime
  end
end
