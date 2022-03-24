class AddArchivingReasonToApplicants < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :archiving_reason, :string
  end
end
