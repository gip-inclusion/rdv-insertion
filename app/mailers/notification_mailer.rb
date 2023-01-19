class NotificationMailerError < StandardError; end

class NotificationMailer < ApplicationMailer
  include Templatable

  before_action :set_applicant, :set_rdv, :set_department, :set_motif_category, :set_rdv_subject,
                :set_signature_lines, :set_rdv_title, :set_applicant_designation,
                :set_display_mandatory_warning, :set_display_punishable_warning,
                :set_rdv_purpose, :set_logo_path, :verify_phone_number_presence

  ### rdv_created ###
  def presential_rdv_created
    mail(
      to: @applicant.email,
      subject: "[Important - RSA] Vous êtes convoqué(e) à un #{@rdv_title}"
    )
  end

  def by_phone_rdv_created
    mail(
      to: @applicant.email,
      subject: "[Important - RSA] Vous êtes convoqué(e) à un #{@rdv_title}"
    )
  end

  ### rdv_updated ###
  def presential_rdv_updated
    mail(
      to: @applicant.email,
      subject: "[Important - RSA] Votre #{@rdv_title} a été modifié."
    )
  end

  def by_phone_rdv_updated
    mail(
      to: @applicant.email,
      subject: "[Important - RSA] Votre #{@rdv_title} a été modifié."
    )
  end

  ### rdv_cancelled ###
  def rdv_cancelled
    mail(
      to: @applicant.email,
      subject: "[Important - RSA] Votre #{@rdv_title} a été annulé."
    )
  end

  private

  def set_applicant
    @applicant = params[:applicant]
  end

  def set_rdv
    @rdv = params[:rdv]
  end

  def set_department
    @department = @applicant.department
  end

  def set_motif_category
    @motif_category = motif_category
  end

  def motif_category
    params[:motif_category]
  end

  def set_signature_lines
    @signature_lines = params[:signature_lines]
  end

  def set_rdv_title
    @rdv_title = rdv_by_phone? ? rdv_title_by_phone : rdv_title
  end

  def set_rdv_subject
    @rdv_subject = rdv_subject
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

  def set_logo_path
    @logo_path = @rdv.organisation.logo_path(%w[png jpg]) || @department.logo_path(%w[png jpg])
  end

  def rdv_by_phone?
    action_name.include?("by_phone")
  end

  def verify_phone_number_presence
    # if we send a notif for a phone rdv we want to be sure the applicant has a phone
    return unless rdv_by_phone?
    return if @applicant.phone_number.present?

    raise(
      NotificationMailerError,
      "No valid phone found for applicant #{@applicant.id}, cannot notify him by phone"
    )
  end
end
