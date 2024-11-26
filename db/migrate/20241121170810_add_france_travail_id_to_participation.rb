class AddFranceTravailIdToParticipation < ActiveRecord::Migration[7.1]
  def change
    add_column :participations, :france_travail_id, :string
  end
end
