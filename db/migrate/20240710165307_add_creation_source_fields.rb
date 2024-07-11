class AddCreationSourceFields < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :created_through, from: "rdv_insertion", to: "rdv_insertion_upload"
    add_column :users, :creation_structure_level, :string, default: "organisation"
    add_column :users, :creation_structure_id, :bigint

    User.where(created_through: "rdv_insertion").update_all(created_through: "rdv_insertion_upload")
  end
end
