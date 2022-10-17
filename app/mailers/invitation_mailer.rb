class InvitationMailer < ApplicationMailer
  before_action :set_invitation, :set_applicant, :set_department,
                :set_logo_path, :set_signature_lines

  def invitation_for_rsa_orientation
    mail(
      to: @applicant.email,
      subject: "Votre RDV d'orientation dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_accompagnement
    mail(
      to: @applicant.email,
      subject: "Votre RDV d'accompagnement dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_orientation_on_phone_platform
    mail(
      to: @applicant.email,
      subject: "Votre RDV d'orientation téléphonique dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_cer_signature
    mail(
      to: @applicant.email,
      subject: "Votre RDV de signature de Contrat d'Engagement Réciproque dans le cadre de votre RSA"
    )
  end

  ### Reminders

  def invitation_for_rsa_orientation_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: RDV d'orientation dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_accompagnement_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: RDV d'accompagnement dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_orientation_on_phone_platform_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: RDV d'orientation téléphonique dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_cer_signature_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: Votre RDV de signature de Contrat d'Engagement Réciproque dans le cadre de votre RSA"
    )
  end

  private

  def set_invitation
    @invitation = params[:invitation]
  end

  def set_applicant
    @applicant = params[:applicant]
  end

  def set_department
    @department = @invitation.department
  end

  def set_signature_lines
    @signature_lines = @invitation.messages_configuration&.signature_lines
  end

  def set_logo_path
    @logo_path = \
      if @invitation.organisations.length == 1 && first_organisation.logo_path.present?
        first_organisation.logo_path
      else
        @department.logo_path
      end
  end

  def first_organisation
    @invitation.organisations.first
  end
end
