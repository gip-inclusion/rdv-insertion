# Preview all emails at http://localhost:8000/rails/mailers/invitation
class InvitationPreview < ActionMailer::Preview
  def first_invitation
    InvitationMailer.first_invitation(Invitation.last, Invitation.last.applicant)
  end
end
