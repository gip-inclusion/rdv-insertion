class AddClosedAtToRdvContext < ActiveRecord::Migration[7.0]
  def change
    add_column :rdv_contexts, :closed_at, :datetime
  end
end
