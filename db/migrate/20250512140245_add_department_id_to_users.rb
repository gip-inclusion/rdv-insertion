class AddDepartmentIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :department, foreign_key: true
    add_index :users, [:nir, :department_id], unique: true, name: "index_users_on_nir_and_department_id"
    add_index :users, [:france_travail_id, :department_id], unique: true,
                                                            name: "index_users_on_france_travail_id_and_department_id"
  end
end
