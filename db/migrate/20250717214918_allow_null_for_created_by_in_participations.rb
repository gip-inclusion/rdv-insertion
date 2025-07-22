class AllowNullForCreatedByInParticipations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :participations, :created_by, true
  end
end
