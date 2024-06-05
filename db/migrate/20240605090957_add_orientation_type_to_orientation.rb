class AddOrientationTypeToOrientation < ActiveRecord::Migration[7.1]
  def change
    add_reference :orientations, :orientation_type, foreign_key: true
  end
end
