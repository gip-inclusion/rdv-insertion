class AddCancelledAtToParticipations < ActiveRecord::Migration[7.0]
  def change
    add_column :participations, :cancelled_at, :datetime, null: true

    up_only do
      execute(<<-SQL.squish
        UPDATE participations SET
        cancelled_at = (SELECT cancelled_at FROM rdvs WHERE participations.rdv_id = rdvs.id)
      SQL
             )
    end
  end
end
