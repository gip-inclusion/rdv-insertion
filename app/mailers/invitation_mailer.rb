class InvitationMailer < ApplicationMailer
  include Templatable

  before_action :set_invitation, :set_applicant, :set_department,
                :set_logo_path, :set_signature_lines

  before_action :set_motif_category, :set_rdv_title, :set_applicant_designation,
                :set_display_mandatory_warning, :set_display_punishable_warning,
                :set_rdv_purpose,
                only: [:regular_invitation, :regular_invitation_reminder]

  def regular_invitation
    mail(
      to: @applicant.email,
      subject: "[RSA]: Votre #{@rdv_title} dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_orientation_on_phone_platform
    mail(
      to: @applicant.email,
      subject: "[RSA]: Votre RDV d'orientation téléphonique dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_insertion_offer
    mail(
      to: @applicant.email,
      subject: "[RSA]: Offre de formations et ateliers dans le cadre de votre parcours socio-professionel"
    )
  end

  ### Reminders

  def regular_invitation_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: Votre #{@rdv_title} dans le cadre de votre RSA"
    )
  end

  def invitation_for_rsa_orientation_on_phone_platform_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel]: RDV d'orientation téléphonique dans le cadre de votre RSA"
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

  def set_motif_category
    @motif_category = @invitation.motif_category
  end

  def motif_category
    @invitation.motif_category
  end

  def set_rdv_title
    @rdv_title = rdv_title
  end

  def set_applicant_designation
    @applicant_designation = applicant_designation
  end

  def set_display_mandatory_warning
    @display_mandatory_warning = display_mandatory_warning
  end

  def set_display_punishable_warning
    @display_punishable_warning = display_punishable_warning
  end

  def set_rdv_purpose
    @rdv_purpose = rdv_purpose
  end

  def first_organisation
    @invitation.organisations.first
  end
end
