class AddConvocableToParticipations < ActiveRecord::Migration[7.0]
  def up
    add_column :participations, :convocable, :boolean, default: false, null: false

    Rdv.where(convocable: true).find_each do |rdv|
      rdv.participations.update_all(convocable: true)
    end

    remove_column :rdvs, :convocable
  end

  def down
    add_column :rdvs, :convocable, :boolean, default: false, null: false

    Participation.where(convocable: true).find_each do |participation|
      participation.rdv.update! convocable: true
    end

    remove_column :participations, :convocable
  end
end
