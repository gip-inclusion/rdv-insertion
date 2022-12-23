class AddRdvContextToParticipations < ActiveRecord::Migration[7.0]
  def change
    add_reference :participations, :rdv_context, foreign_key: true
    up_only do
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
    end
    # TODO : Penser à supprimer la table rdv_contexts_rdvs une fois la migration achevée et que tout est ok
  end
end
