class AddColumnsToApplicants < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :last_organisation_joined_at, :datetime, default: -> { "now()" }
    add_column :applicants, :last_rdv_context_joined_at, :datetime, default: -> { "now()" }
  end
end
