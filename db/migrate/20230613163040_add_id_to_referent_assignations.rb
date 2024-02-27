class AddIdToReferentAssignations < ActiveRecord::Migration[7.0]
  # rubocop:disable Rails/DangerousColumnNames
  def change
    add_column :referent_assignations, :id, :primary_key
  end
  # rubocop:enable Rails/DangerousColumnNames
end
