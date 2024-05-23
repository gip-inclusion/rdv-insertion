class RemoveMotifCateogryIdToCsvExportAndAddRequestParams < ActiveRecord::Migration[7.1]
  def change
    remove_column :csv_exports, :motif_category_id, :integer
    add_column :csv_exports, :request_params, :json
  end
end
