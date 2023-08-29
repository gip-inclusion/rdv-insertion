class AddTagsColumnToFileConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :file_configurations, :tags_column, :string
  end
end
