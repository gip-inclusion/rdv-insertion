class SoftDeleteUserJob < ApplicationJob
  def perform(rdv_solidarites_user_id)
    user = User.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
    return if user.blank? || user.deleted?

    user.soft_delete
    MattermostClient.send_to_notif_channel(
      "RDV Solidarites user #{rdv_solidarites_user_id} deleted"
    )
  end
end
