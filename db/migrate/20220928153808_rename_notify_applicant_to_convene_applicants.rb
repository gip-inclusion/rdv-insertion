class RenameNotifyApplicantToConveneApplicants < ActiveRecord::Migration[7.0]
  def change
    rename_column :configurations, :notify_applicant, :convene_applicant
  end
end
