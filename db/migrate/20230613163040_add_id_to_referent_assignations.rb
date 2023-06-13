class AddIdToReferentAssignations < ActiveRecord::Migration[7.0]
  def change
    add_column :referent_assignations, :id, :primary_key
  end
end
