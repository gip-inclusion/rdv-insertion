class AddDepartmentIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :department, foreign_key: true
  end
end
