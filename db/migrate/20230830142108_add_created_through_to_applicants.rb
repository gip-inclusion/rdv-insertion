class AddCreatedThroughToApplicants < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :created_through, :integer, default: 0
    up_only { Applicant.where(title: nil).update_all(created_through: 1) }
  end
end
