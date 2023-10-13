class AddPositionToConfiguration < ActiveRecord::Migration[7.0]
  def change
    add_column :configurations, :position, :integer
  end
end
