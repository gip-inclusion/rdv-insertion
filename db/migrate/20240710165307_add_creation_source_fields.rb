class AddCreationSourceFields < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :created_through, from: "rdv_insertion", to: nil
    add_reference :users, :created_from, polymorphic: true, index: true
    change_column_default :users, :created_from_type, from: nil, to: "Organisation"

    User.where(created_through: "rdv_insertion").update_all(created_through: nil)
  end
end
