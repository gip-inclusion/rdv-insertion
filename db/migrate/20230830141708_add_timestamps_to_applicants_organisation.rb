class AddTimestampsToApplicantsOrganisation < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants_organisations, :id, :primary_key
    add_column :applicants_organisations, :created_at, :datetime
    add_column :applicants_organisations, :updated_at, :datetime
  end
end
