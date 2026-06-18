class AddUniqueIndexToCreneauOpeningRequests < ActiveRecord::Migration[8.1]
  def change
    remove_index :creneau_opening_requests, :user_list_upload_id
    add_index :creneau_opening_requests, %i[user_list_upload_id recipient_agent_id], unique: true
  end
end
