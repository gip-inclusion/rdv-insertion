class AddStatusAndIdToApplicantsRdvs < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants_rdvs, :status, :integer
    add_column :applicants_rdvs, :rdv_solidarites_participation_id, :bigint
    add_column :applicants_rdvs, :id, :primary_key
    add_index :applicants_rdvs, :status
    add_timestamps :applicants_rdvs, null: true

    long_ago = DateTime.new(2000, 1, 1)
    Participation.update_all(created_at: long_ago, updated_at: long_ago)

    change_column_null :applicants_rdvs, :created_at, false
    change_column_null :applicants_rdvs, :updated_at, false

    up_only do
      execute(<<-SQL.squish
        UPDATE applicants_rdvs SET status = (SELECT status FROM rdvs WHERE applicants_rdvs.rdv_id = rdvs.id)
      SQL
             )
    end
  end
end
