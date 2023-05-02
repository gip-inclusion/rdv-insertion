class ChangeApplicantsIndices < ActiveRecord::Migration[7.0]
  def change
    # we remove and re-add the uid index to remove its uniqueness constraint
    remove_index :applicants, :uid
    add_index :applicants, :uid
    add_index :applicants, :nir
    add_index :applicants, :email
    add_index :applicants, :phone_number
    add_index :applicants, :department_internal_id
  end
end
