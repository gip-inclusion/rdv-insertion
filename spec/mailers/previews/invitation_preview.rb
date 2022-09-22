# Preview all emails at http://localhost:8000/rails/mailers/invitation
class InvitationPreview < ActionMailer::Preview
  def invitation_for_rsa_orientation
    invitation = Invitation.where(format: "email").last # create a local mail invitation if there are none
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_orientation
  end

  def invitation_for_rsa_accompagnement
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_accompagnement
  end

  def invitation_for_rsa_orientation_on_phone_platform
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_orientation_on_phone_platform
  end

  def invitation_for_rsa_cer_signature
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_cer_signature
  end

  ### Reminders

  def invitation_for_rsa_orientation_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_orientation_reminder
  end

  def invitation_for_rsa_accompagnement_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_accompagnement_reminder
  end

  def invitation_for_rsa_orientation_on_phone_platform_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_orientation_on_phone_platform_reminder
  end

  def invitation_for_rsa_cer_signature_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_cer_signature_reminder
  end
end
