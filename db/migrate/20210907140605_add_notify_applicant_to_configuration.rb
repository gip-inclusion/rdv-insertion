class AddNotifyApplicantToConfiguration < ActiveRecord::Migration[6.1]
  def change
    add_column :configurations, :notify_applicant, :boolean, default: false
  end
end
