# Preview all emails at http://localhost:8000/rails/mailers/invitation
class InvitationPreview < ActionMailer::Preview
  def first_invitation
    invitation = Invitation.where(format: "email").last # create a local mail invitation if there are none
    InvitationMailer.first_invitation(invitation, invitation.applicant)
  end
end
