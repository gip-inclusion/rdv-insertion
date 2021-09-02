class AddColumnNamesToConfiguration < ActiveRecord::Migration[6.1]
  def change
    change_table :configurations, bulk: true do |t|
      t.column :column_names, :json
    end
  end
end
