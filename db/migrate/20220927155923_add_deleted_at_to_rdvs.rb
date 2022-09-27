class AddDeletedAtToRdvs < ActiveRecord::Migration[7.0]
  def change
    add_column :rdvs, :deleted_at, :datetime
  end
end
