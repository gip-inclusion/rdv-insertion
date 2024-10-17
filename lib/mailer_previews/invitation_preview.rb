# Preview all emails at http://localhost:8000/rails/mailers/invitation
class InvitationPreview < ActionMailer::Preview
  invitation = Invitation.format_email.first
  user = invitation.user
  user.assign_attributes(
    first_name: "Camille", last_name: "Martin", title: "madame",
    address: "49 Rue Cavaignac, 13003 Marseille"
  )
  invitation.expires_at = 5.days.from_now

  # we don't set current_category_configuration, so that invitation.rdv_title_by_phone, invitation.rdv_title,
  # invitation.user_designation, notification.rdv_purpose returns the values from the template and not
  # from current_category_configuration.***_override attributes. These methods are implemented in the Templatable concern
  invitation.define_singleton_method(:current_category_configuration) { nil }

  MotifCategory.find_each do |motif_category|
    follow_up = FollowUp.new(motif_category: motif_category, user: user)
    invitation.follow_up = follow_up

    define_method motif_category.short_name do
      InvitationMailer.with(invitation: invitation, user: invitation.user)
                      .send("#{motif_category.template_model}_invitation")
    end

    define_method "#{motif_category.short_name}_rappel" do
      InvitationMailer.with(invitation: invitation, user: invitation.user)
                      .send("#{motif_category.template_model}_invitation_reminder")
    end
  end
end
