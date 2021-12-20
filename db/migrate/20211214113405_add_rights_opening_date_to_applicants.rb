class AddRightsOpeningDateToApplicants < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :rights_opening_date, :date
  end
end
