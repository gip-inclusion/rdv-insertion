class InvitationMailer < ApplicationMailer
  def invitation_for_rsa_orientation(invitation, applicant)
    @invitation = invitation
    @department = @invitation.department
    @invitation_parameters = @invitation.invitation_parameters
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "RDV d'orientation dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_accompagnement(invitation, applicant)
    @invitation = invitation
    @department = @invitation.department
    @invitation_parameters = @invitation.invitation_parameters
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "RDV d'accompagnement dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_orientation_on_phone_platform(invitation, applicant)
    @invitation = invitation
    @department = @invitation.department
    @invitation_parameters = @invitation.invitation_parameters
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "RDV d'orientation téléphonique dans le cadre de votre RSA"
    )
  end

  ### Reminders

  def invitation_for_rsa_orientation_reminder(invitation, applicant)
    @invitation = invitation
    @department = @invitation.department
    @invitation_parameters = @invitation.invitation_parameters
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "[Rappel]: RDV d'orientation dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_accompagnement_reminder(invitation, applicant)
    @invitation = invitation
    @department = @invitation.department
    @invitation_parameters = @invitation.invitation_parameters
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "[Rappel]: RDV d'accompagnement dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_orientation_on_phone_platform_reminder(invitation, applicant)
    @invitation = invitation
    @department = @invitation.department
    @invitation_parameters = @invitation.invitation_parameters
    @applicant = applicant
    mail(
      to: @applicant.email,
      subject: "[Rappel]: RDV d'orientation téléphonique dans le cadre de votre RSA"
    )
  end
end
