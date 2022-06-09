class RenameContextToMotifCategory < ActiveRecord::Migration[7.0]
  def change
    rename_column :rdv_contexts, :context, :motif_category
    rename_column :configurations, :context, :motif_category
  end
end
