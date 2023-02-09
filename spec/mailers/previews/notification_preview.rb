# Preview all emails at http://localhost:8000/rails/mailers/notification
class NotificationPreview < ActionMailer::Preview
  MotifCategory.participation_optional(false).find_each do |motif_category|
    notification = \
      Notification
      .joins(:participation)
      .where(
        participation: Participation.joins(:applicant, :rdv).where.not(applicant: { phone_number: nil })
                                                              .where.not(rdv: { lieu_id: nil })
      ).first
    participation = notification.participation
    rdv_context = RdvContext.new(motif_category: motif_category, applicant: participation.applicant)
    participation.rdv_context = rdv_context

    define_method "#{motif_category.short_name}_presential_participation_created" do
      NotificationMailer.with(notification: notification)
                        .send("presential_participation_created")
    end

    define_method "#{motif_category.short_name}_presential_participation_updated" do
      NotificationMailer.with(notification: notification)
                        .send("presential_participation_updated")
    end

    define_method "#{motif_category.short_name}_by_phone_participation_created" do
      NotificationMailer.with(notification: notification)
                        .send("by_phone_participation_created")
    end

    define_method "#{motif_category.short_name}_by_phone_participation_updated" do
      NotificationMailer.with(notification: notification)
                        .send("by_phone_participation_updated")
    end

    define_method "#{motif_category.short_name}_participation_cancelled" do
      NotificationMailer.with(notification: notification)
                        .send("participation_cancelled")
    end
  end
end
