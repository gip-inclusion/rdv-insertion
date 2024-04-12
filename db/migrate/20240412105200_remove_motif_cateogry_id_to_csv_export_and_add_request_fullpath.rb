class RemoveMotifCateogryIdToCsvExportAndAddRequestFullpath < ActiveRecord::Migration[7.1]
  def change
    remove_column :csv_exports, :motif_category_id, :integer
  end
end
