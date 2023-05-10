class AddCreatedByToParticipations < ActiveRecord::Migration[7.0]
  def up
    add_column :participations, :created_by, :string, null: true

    # migrate created_by :agent
    execute(<<-SQL.squish
      UPDATE participations
      SET created_by = 'agent'
      FROM rdvs
      WHERE participations.rdv_id = rdvs.id
      AND rdvs.created_by = 0
    SQL
           )

    # migrate created_by :user
    execute(<<-SQL.squish
      UPDATE participations
      SET created_by = 'user'
      FROM rdvs
      WHERE participations.rdv_id = rdvs.id
      AND rdvs.created_by = 1
    SQL
           )

    # migrate created_by :file_attente to user
    execute(<<-SQL.squish
      UPDATE participations
      SET created_by = 'user'
      FROM rdvs
      WHERE participations.rdv_id = rdvs.id
      AND rdvs.created_by = 2
    SQL
           )

    # migrate created_by :prescripteur
    execute(<<-SQL.squish
      UPDATE participations
      SET created_by = 'prescripteur'
      FROM rdvs
      WHERE participations.rdv_id = rdvs.id
      AND rdvs.created_by = 3
    SQL
           )

    change_column_null :participations, :created_by, false
  end

  def down
    remove_column :participations, :created_by, :string
  end
end
