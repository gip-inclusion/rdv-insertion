class InvitationMailer < ApplicationMailer
  before_action :set_invitation, :set_applicant, :set_department, :set_logo_name, :set_logo_format, :set_invitation_parameters

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

  def set_invitation_parameters
    @invitation_parameters = @invitation.invitation_parameters
  end

  def set_logo_name
    @logo_name = if !department_level? && logo_is_present(organisation_name)
                   organisation_name
                 else
                   @department.name.parameterize
                 end
  end

  def set_logo_format
    @logo_format = %w[svg png jpg].find do |format|
      Webpacker.manifest.lookup("media/images/logos/#{@logo_name}.#{format}")
    end
  end

  def department_level?
    @invitation.organisations.size > 1
  end

  def logo_is_present(organisation_name)
    Webpacker.manifest.lookup("media/images/logos/#{organisation_name}.svg") ||
      Webpacker.manifest.lookup("media/images/logos/#{organisation_name}.png") ||
      Webpacker.manifest.lookup("media/images/logos/#{organisation_name}.jpg")
  end

  def organisation_name
    @organisation_name ||= @invitation.organisations.first.name.parameterize
  end
end
