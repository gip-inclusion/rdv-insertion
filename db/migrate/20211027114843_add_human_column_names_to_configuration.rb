class AddHumanColumnNamesToConfiguration < ActiveRecord::Migration[6.1]
  def change
    add_column :configurations, :human_column_names, :json
  end
end
