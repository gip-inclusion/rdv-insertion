class AddContextToConfigurations < ActiveRecord::Migration[6.1]
  def change
    add_column :configurations, :context, :integer, default: 0
  end
end
