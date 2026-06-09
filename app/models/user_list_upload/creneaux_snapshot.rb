class UserListUpload::CreneauxSnapshot < ApplicationRecord
  self.table_name = "user_list_upload_creneaux_snapshots"

  belongs_to :user_list_upload
  delegate :user_rows_selected_for_invitation, to: :user_list_upload

  validates :number_of_creneaux_available, presence: true

  def no_creneaux_available?
    number_of_creneaux_available.zero?
  end

  def insufficient_creneaux?
    number_of_creneaux_available < user_rows_selected_for_invitation.size
  end
end
