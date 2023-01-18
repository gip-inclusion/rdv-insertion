class AddRdvContextToParticipations < ActiveRecord::Migration[7.0]
  def up
    add_reference :participations, :rdv_context, foreign_key: true
    execute(<<-SQL.squish
      UPDATE participations SET
      rdv_context_id = (
        SELECT rdv_contexts.id FROM rdv_contexts
        JOIN rdv_contexts_rdvs ON rdv_contexts_rdvs.rdv_context_id = rdv_contexts.id
        JOIN rdvs ON rdv_contexts_rdvs.rdv_id = rdvs.id
        WHERE participations.applicant_id = rdv_contexts.applicant_id
        AND participations.rdv_id = rdvs.id)
    SQL
           )
    drop_table :rdv_contexts_rdvs
  end

  def down
    create_join_table :rdvs, :rdv_contexts do |t|
      t.index([:rdv_id, :rdv_context_id], unique: true)
    end
    execute(<<-SQL.squish
      INSERT INTO rdv_contexts_rdvs (rdv_context_id, rdv_id)
      SELECT rdv_context_id, rdv_id FROM participations
    SQL
           )
    remove_reference :participations, :rdv_context, foreign_key: true
  end
end
