class AddCreationSourceFields < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :created_through, from: "rdv_insertion", to: nil
    add_reference :users, :created_from_structure, polymorphic: true, index: true

    User.where(created_through: "rdv_insertion").update_all(created_through: nil)
    User.where(created_through: "rdv_solidarites").update_all(created_through: "rdv_solidarites_webhook")
  end
end
