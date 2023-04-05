class RemoveDepartmentFromApplicants < ActiveRecord::Migration[7.0]
  def change
    remove_reference :applicants, :department, null: false, foreign_key: true
  end
end
