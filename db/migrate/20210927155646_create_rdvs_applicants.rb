class CreateRdvsApplicants < ActiveRecord::Migration[6.1]
  def change
    create_join_table :applicants, :rdvs do |t|
      t.index [:applicant_id, :rdv_id], unique: true
    end
  end
end
