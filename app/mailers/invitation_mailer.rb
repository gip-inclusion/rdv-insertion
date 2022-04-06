class InvitationMailer < ApplicationMailer
  def invitation_for_rsa_orientation(invitation, applicant)
    @invitation = invitation
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "Prenez RDV d'orientation pour votre RSA"
    )
  end

  def invitation_for_rsa_accompagnement(invitation, applicant)
    @invitation = invitation
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "Prenez RDV d'accompagnement pour votre RSA"
    )
  end

  def invitation_for_rsa_orientation_phone_platform(invitation, applicant)
    @invitation = invitation
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "Prenez RDV d'orientation pour votre RSA"
    )
  end
end
