class AddStatusAndIdToApplicantsRdvs < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants_rdvs, :status, :integer, default: 0
    add_column :applicants_rdvs, :rdv_solidarites_participation_id, :bigint
    add_column :applicants_rdvs, :id, :primary_key
    add_index :applicants_rdvs, :status
    add_timestamps :applicants_rdvs, null: true

    up_only do
      execute(<<-SQL.squish
        UPDATE applicants_rdvs SET
        status = (SELECT status FROM rdvs WHERE applicants_rdvs.rdv_id = rdvs.id),
        created_at = (SELECT created_at FROM rdvs WHERE applicants_rdvs.rdv_id = rdvs.id),
        updated_at = (SELECT updated_at FROM rdvs WHERE applicants_rdvs.rdv_id = rdvs.id)
      SQL
             )
    end

    change_column_null :applicants_rdvs, :created_at, false
    change_column_null :applicants_rdvs, :updated_at, false
  end
end
