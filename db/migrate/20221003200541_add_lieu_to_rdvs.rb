class AddLieuToRdvs < ActiveRecord::Migration[7.0]
  def up
    add_reference :rdvs, :lieu, foreign_key: true
    Rdv.find_each do |rdv|
      lieu = Lieu.find_by(rdv_solidarites_lieu_id: rdv.rdv_solidarites_lieu_id)
      next unless lieu

      rdv.update!(lieu_id: lieu.id)
    end
    remove_column :rdvs, :rdv_solidarites_lieu_id
  end

  def down
    add_column :rdvs, :rdv_solidarites_lieu_id
    Rdv.find_each do |rdv|
      next unless rdv.lieu_id?

      rdv.update!(rdv_solidarites_lieu_id: rdv.lieu.rdv_solidarites_lieu_id)
    end
    remove_reference :rdvs, :lieu, foreign_key: true
  end
end
