class InvitationMailer < ApplicationMailer
  before_action :set_invitation, :set_applicant, :set_department, :set_signature_lines,
                :set_organisation_logo_path, :set_department_logo_path

  before_action :set_rdv_title, :set_applicant_designation, :set_mandatory_warning, :set_punishable_warning,
                :set_rdv_purpose, :set_rdv_subject, :set_custom_sentence

  def standard_invitation
    mail(
      to: @applicant.email,
      subject: "[#{@rdv_subject.upcase}]: Votre #{@rdv_title} dans le cadre de votre #{@rdv_subject}"
    )
  end

  def short_invitation
    mail(
      to: @applicant.email,
      subject: "Votre #{@rdv_title}"
    )
  end

  def phone_platform_invitation
    mail(
      to: @applicant.email,
      subject: "[#{@rdv_subject.upcase}]: Votre #{@rdv_title} dans le cadre de votre #{@rdv_subject}"
    )
  end

  def atelier_invitation
    mail(
      to: @applicant.email,
      subject: "[#{@rdv_subject.upcase}]: Participer à un atelier dans le cadre de votre parcours"
    )
  end

  def atelier_enfants_ados_invitation
    mail(
      to: @applicant.email,
      subject: "Invitation à un #{@rdv_title}"
    )
  end

  ### Reminders

  def short_invitation_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: Votre #{@rdv_title}"
    )
  end

  def standard_invitation_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: Votre #{@rdv_title} dans le cadre de votre #{@rdv_subject}"
    )
  end

  def phone_platform_invitation_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: Votre #{@rdv_title} dans le cadre de votre #{@rdv_subject}"
    )
  end

  def atelier_enfants_ados_invitation_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: Invitation à un #{@rdv_title}"
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

  def set_organisation_logo_path
    return if @invitation.organisations.length != 1 || first_organisation.logo_path(%w[png jpg]).blank?

    @organisation_logo_path = first_organisation.logo_path(%w[png jpg])
  end

  def set_department_logo_path
    @department_logo_path = @department.logo_path(%w[png jpg])
  end

  def set_rdv_title
    @rdv_title = @invitation.rdv_title
  end

  def set_rdv_subject
    @rdv_subject = @invitation.rdv_subject
  end

  def set_applicant_designation
    @applicant_designation = @invitation.applicant_designation
  end

  def set_mandatory_warning
    @mandatory_warning = @invitation.mandatory_warning
  end

  def set_punishable_warning
    @punishable_warning = @invitation.punishable_warning
  end

  def set_rdv_purpose
    @rdv_purpose = @invitation.rdv_purpose
  end

  def set_custom_sentence
    @custom_sentence = @invitation.custom_sentence
  end

  def first_organisation
    @invitation.organisations.first
  end
end
