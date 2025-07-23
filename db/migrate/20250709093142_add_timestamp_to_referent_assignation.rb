class AddTimestampToReferentAssignation < ActiveRecord::Migration[8.0]
  def change
    add_timestamps :referent_assignations, null: false, default: -> { "CURRENT_TIMESTAMP" }
    change_column_null :referent_assignations, :created_at, false
    change_column_null :referent_assignations, :updated_at, false

    change_column_default :referent_assignations, :created_at, from: -> { "CURRENT_TIMESTAMP" }, to: nil
    change_column_default :referent_assignations, :updated_at, from: -> { "CURRENT_TIMESTAMP" }, to: nil
  end
end
