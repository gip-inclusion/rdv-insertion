class AddArchivingReasonToApplicants < ActiveRecord::Migration[6.1]
  def up
    add_column :applicants, :archiving_reason, :string
  end

  def down
    remove_column :applicants, :archiving_reason
  end
end
