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
      subject: "Votre RDV d'accompagnement dans le cadre de votre RSA",
      template_name: "invitation_for_rsa_accompagnement"
    )
  end
  alias invitation_for_rsa_accompagnement_social invitation_for_rsa_accompagnement
  alias invitation_for_rsa_accompagnement_sociopro invitation_for_rsa_accompagnement

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

  def invitation_for_rsa_follow_up
    mail(
      to: @applicant.email,
      subject: "Votre RDV de suivi avec votre référent de parcours"
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
      subject: "[Rappel]: RDV d'accompagnement dans le cadre de votre RSA",
      template_name: "invitation_for_rsa_accompagnement_reminder"
    )
  end
  alias invitation_for_rsa_accompagnement_social_reminder invitation_for_rsa_accompagnement_reminder
  alias invitation_for_rsa_accompagnement_sociopro_reminder invitation_for_rsa_accompagnement_reminder

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

  def invitation_for_rsa_follow_up_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: Votre RDV de suivi avec votre référent de parcours"
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
        first_organisation.logo_path(%w[png jpg])
      else
        @department.logo_path(%w[png jpg])
      end
  end

  def first_organisation
    @invitation.organisations.first
  end
end
