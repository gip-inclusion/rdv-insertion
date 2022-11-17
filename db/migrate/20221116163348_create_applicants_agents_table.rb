class CreateApplicantsAgentsTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :applicants, :agents do |t|
      t.index [:applicant_id, :agent_id], unique: true
    end
  end
end
