# Preview all emails at http://localhost:8000/rails/mailers/invitation
class InvitationPreview < ActionMailer::Preview
  def invitation_for_rsa_orientation
    invitation = Invitation.where(format: "email").last # create a local mail invitation if there are none
    InvitationMailer.invitation_for_rsa_orientation(invitation, invitation.applicant)
  end

  def invitation_for_rsa_accompagnement
    invitation = Invitation.where(format: "email").last
    InvitationMailer.invitation_for_rsa_accompagnement(invitation, invitation.applicant)
  end

  def invitation_for_rsa_orientation_on_phone_platform
    invitation = Invitation.where(format: "email").last
    InvitationMailer.invitation_for_rsa_orientation_on_phone_platform(invitation, invitation.applicant)
  end

  ### Reminders

  def invitation_for_rsa_orientation_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.invitation_for_rsa_orientation_reminder(invitation, invitation.applicant)
  end

  def invitation_for_rsa_accompagnement_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.invitation_for_rsa_accompagnement_reminder(invitation, invitation.applicant)
  end

  def invitation_for_rsa_orientation_on_phone_platform_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.invitation_for_rsa_orientation_on_phone_platform_reminder(invitation, invitation.applicant)
  end
end
