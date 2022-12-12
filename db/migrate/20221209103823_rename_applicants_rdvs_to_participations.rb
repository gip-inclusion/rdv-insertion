class RenameApplicantsRdvsToParticipations < ActiveRecord::Migration[7.0]
  def change
    rename_table(:applicants_rdvs, :participations)
  end
end
