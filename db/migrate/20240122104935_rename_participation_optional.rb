class RenameParticipationOptional < ActiveRecord::Migration[7.0]
  def change
    rename_column :motif_categories, :participation_optional, :optional_rdv_subscription
  end
end
