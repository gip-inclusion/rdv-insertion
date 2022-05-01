class AddOrientationDateToApplicant < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :orientation_date, :datetime

    up_only do
      Applicant.all.each do |applicant|
        applicant.update_orientation_date
        applicant.save!
      end
    end
  end
end
