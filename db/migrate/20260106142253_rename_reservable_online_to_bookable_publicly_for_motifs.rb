class RenameReservableOnlineToBookablePubliclyForMotifs < ActiveRecord::Migration[8.0]
  def change
    rename_column :motifs, :reservable_online, :bookable_publicly
  end
end
