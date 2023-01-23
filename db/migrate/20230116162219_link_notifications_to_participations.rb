class LinkNotificationsToParticipations < ActiveRecord::Migration[7.0]
  def up
    add_reference :notifications, :participation, foreign_key: true
    Notification.find_each do |notification|
      participation = Participation.find_by(applicant: notification.applicant_id, rdv: notification.rdv_id)
      notification.update_columns(
        participation_id: participation.id,
        rdv_solidarites_rdv_id: participation.rdv_solidarites_rdv_id
      )
    end
    remove_reference :notifications, :rdv
    remove_reference :notifications, :applicant
  end

  def down
    add_reference :notifications, :rdv, foreign_key: true
    add_reference :notifications, :applicant, foreign_key: true

    Notification.find_each do |notification|
      participation = Participation.find(notification.participation_id)
      notification.update_columns(
        rdv_id: participation.rdv_id, applicant_id: participation.applicant_id
      )
    end

    remove_reference :notifications, :participation
  end
end
