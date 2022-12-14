class CreateRdvContextsParticipationsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :participations, :rdv_contexts do |t|
      t.index(
        [:participation_id, :rdv_context_id],
        unique: true,
        name: "index_particips_rdv_contexts_on_rdv_context_id_and_particip_id"
      )
    end
  end
end
