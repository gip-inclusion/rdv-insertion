class RenameAgentsApplicantsToReferentAssignations < ActiveRecord::Migration[7.0]
  def change
    rename_table :agents_applicants, :referent_assignations
  end
end
