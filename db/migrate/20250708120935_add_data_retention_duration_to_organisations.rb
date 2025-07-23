class AddDataRetentionDurationToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :data_retention_duration_in_months, :integer, null: false, default: 24
  end
end
