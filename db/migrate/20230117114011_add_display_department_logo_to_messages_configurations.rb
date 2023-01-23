class AddDisplayDepartmentLogoToMessagesConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :messages_configurations, :display_department_logo, :boolean, default: true
  end
end
