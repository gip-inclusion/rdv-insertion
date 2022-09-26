class AddMotifToRdvs < ActiveRecord::Migration[7.0]
  def up
    add_reference :rdvs, :motif, foreign_key: true
    Rdv.find_each do |rdv|
      motif = Motif.find_by(rdv_solidarites_motif_id: rdv.rdv_solidarites_motif_id)
      rdv.update!(motif_id: motif.id)
    end
    remove_column :rdvs, :rdv_solidarites_motif_id
  end

  def down
    add_column :rdvs, :rdv_solidarites_motif_id
    Rdv.find_each do |rdv|
      rdv.update!(rdv_solidarites_motif_id: rdv.motif.rdv_solidarites_motif_id)
    end
    remove_reference :rdvs, :motif, foreign_key: true
  end
end
