# Preview all emails at http://localhost:8000/rails/mailers/notification
class NotificationPreview < ActionMailer::Preview
  notification =
    Notification.joins(participation: :user).where(participation: { user: User.active }).format_email
                .first
  user = notification.user
  user.assign_attributes(
    first_name: "Camille", last_name: "Martin", title: "madame", email: "camille@gouv.fr"
  )
  # we don't set current_category_configuration, so that notification.rdv_title_by_phone, notification.rdv_title,
  # notification.user_designation, notification.rdv_purpose returns the values from the template and not
  # from current_category_configuration.***_override attributes. These methods are implemented in the Templatable concern
  notification.define_singleton_method(:current_category_configuration) { nil }

  MotifCategory.find_each do |motif_category|
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