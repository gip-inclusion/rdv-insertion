# Preview all emails at http://localhost:8000/rails/mailers/invitation
class InvitationPreview < ActionMailer::Preview
  def invitation_for_rsa_orientation
    invitation = Invitation.where(format: "email").last # create a local mail invitation if there are none
    InvitationMailer.invitation_for_rsa_orientation(invitation, invitation.applicant)
  end

  def invitation_for_rsa_accompagnement
    invitation = Invitation.where(format: "email").last # create a local mail invitation if there are none
    InvitationMailer.invitation_for_rsa_accompagnement(invitation, invitation.applicant)
  end

  def invitation_for_rsa_orientation_on_phone_platform
    invitation = Invitation.where(format: "email").last # create a local mail invitation if there are none
    InvitationMailer.invitation_for_rsa_orientation_on_phone_platform(invitation, invitation.applicant)
  end
end
