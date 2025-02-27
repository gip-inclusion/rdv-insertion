class AddDpaIdentityToDpaAgreement < ActiveRecord::Migration[8.0]
  def change
    add_column :dpa_agreements, :agent_email, :string
    add_column :dpa_agreements, :agent_full_name, :string
    change_column_null :dpa_agreements, :agent_id, true
  end
end
