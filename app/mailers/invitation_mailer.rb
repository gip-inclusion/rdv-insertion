class InvitationMailer < ApplicationMailer
  def first_invitation(invitation, applicant)
    @invitation = invitation
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "Prenez RDV pour votre RSA"
    )
  end
end
