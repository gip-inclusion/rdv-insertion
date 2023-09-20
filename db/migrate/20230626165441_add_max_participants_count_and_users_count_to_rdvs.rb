class AddMaxParticipantsCountAndApplicantsCountToRdvs < ActiveRecord::Migration[7.0]
  def change
    add_column :rdvs, :users_count, :integer, default: 0
    add_column :rdvs, :max_participants_count, :integer
  end
end
