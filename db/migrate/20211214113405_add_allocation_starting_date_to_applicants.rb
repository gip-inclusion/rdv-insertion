class AddAllocationStartingDateToApplicants < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :allocation_starting_date, :date
  end
end
