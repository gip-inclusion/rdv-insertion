class RemoveNotNullConstraintFromAgentsInOrientations < ActiveRecord::Migration[7.0]
  def change
    change_column_null :orientations, :agent_id, true
  end
end
