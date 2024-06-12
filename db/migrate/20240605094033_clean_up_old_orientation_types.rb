class CleanUpOldOrientationTypes < ActiveRecord::Migration[7.1]
  def up
    Orientation.where(orientation_type: nil).find_each do |orientation|
      orientation.orientation_type = OrientationType.find_by(
        casf_category: orientation.attributes["orientation_type"],
        department_id: nil
      )
      orientation.save!
    end

    remove_column :orientations, :orientation_type, :string
  end

  def down
    add_column :orientations, :orientation_type, :string
    Orientation.find_each do |orientation|
      orientation.update_column(:orientation_type, orientation.orientation_type.casf_category)
    end
  end
end
