class AddOrganisationIdToStats < ActiveRecord::Migration[7.0]
  def up
    add_reference :stats, :statable, polymorphic: true, index: true

    Stat.find_each do |stat|
      stat.statable_type = stat.department_number.present? ? "Department" : "Organisation"
      if stat.department_number.present? && stat.department_number != "all"
        department = Department.find_by(number: stat.department_number)
        stat.statable_id = department.id
      end
      stat.save!
    end

    remove_column :stats, :department_number
  end

  def down
    add_column :stats, :department_number, :string

    Stat.where(statable_type: "Organisation").destroy_all
    Stat.find_each do |stat|
      next unless stat.statable_type == "Department"

      if stat.statable_id.nil?
        stat.department_number = "all"
      else
        department = Department.find(stat.statable_id)
        stat.department_number = department.number
      end
      stat.save!
    end

    remove_reference :stats, :statable, polymorphic: true
  end
end
