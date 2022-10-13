class InvitationMailer < ApplicationMailer
  before_action :set_invitation, :set_applicant, :set_department, :set_department_or_organisation_logo_name,
                :set_logo_format, :set_messages_configuration

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

  def set_messages_configuration
    @messages_configuration = @invitation.messages_configuration
  end

  def set_department_or_organisation_logo_name
    @logo_name = ComputeOrganisationOrDepartmentLogoName.call(
      department_name: @department.name.parameterize,
      organisation_name: organisation_name
    ).logo_name
  end

  def set_logo_format
    @logo_format = ComputeLogoFormat.call(logo_name: @logo_name).format
  end

  def organisation
    @organisation ||= @invitation.organisations.size > 1 ? nil : @invitation.organisations.first
  end

  def organisation_name
    @organisation_name ||= organisation.present? ? organisation.name.parameterize : nil
  end
end
