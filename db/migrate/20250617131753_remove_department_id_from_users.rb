class RemoveDepartmentIdFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_reference :users, :department, foreign_key: true
  end
end
