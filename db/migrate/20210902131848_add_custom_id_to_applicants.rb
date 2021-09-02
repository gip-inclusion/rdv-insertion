class AddCustomIdToApplicants < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :custom_id, :string
  end
end
