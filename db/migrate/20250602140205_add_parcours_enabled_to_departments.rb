class AddParcoursEnabledToDepartments < ActiveRecord::Migration[8.0]
  def change
    add_column :departments, :parcours_enabled, :boolean, default: true

    Department.where(number: ENV.fetch("DEPARTMENTS_WHERE_PARCOURS_DISABLED", "").split(",")).find_each do |department|
      department.update!(parcours_enabled: false)
    end
  end
end
