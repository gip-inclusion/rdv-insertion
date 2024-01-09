# rails runner scripts/report_old_ressources_to_destroy.rb

def report_inactive_users_to_destroy
  destroyed_user_ids = User.left_outer_joins(:invitations, :participations, :users_organisations)
                           .where("users.created_at < ?", date_limit)
                           .where("NOT EXISTS (SELECT 1
                                       FROM invitations
                                       WHERE invitations.user_id = users.id AND (invitations.created_at >= ?)
                                   )", date_limit)
                           .where("NOT EXISTS (SELECT 1
                                       FROM participations
                                       WHERE participations.user_id = users.id AND (participations.created_at >= ?)
                                   )", date_limit)
                           .where("NOT EXISTS (SELECT 1
                                       FROM users_organisations
                                       WHERE users_organisations.user_id = users.id
                                       AND (users_organisations.created_at >= ?)
                                   )", date_limit)
                           .distinct
                           .pluck(:id)

  puts "Inactive Users to be destroyed: #{destroyed_user_ids}"
end

def report_useless_rdvs_to_destroy
  destroyed_rdv_ids = Rdv.where.missing(:participations).where("rdvs.created_at < ?", date_limit).pluck(:id)

  puts "Useless RDVs to be destroyed: #{destroyed_rdv_ids}"
end

def report_useless_notifications_to_destroy
  destroyed_notification_ids = Notification.where(participation_id: nil)
                                           .where("created_at < ?", date_limit)
                                           .pluck(:id)

  puts "Useless Notifications to be destroyed: #{destroyed_notification_ids}"
end

def date_limit
  2.years.ago
end

# Run the reports
report_inactive_users_to_destroy
report_useless_rdvs_to_destroy
report_useless_notifications_to_destroy
