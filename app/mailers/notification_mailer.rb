class NotificationMailerError < StandardError; end

class NotificationMailer < ApplicationMailer
  before_action :set_notification, :set_applicant, :set_rdv, :set_department, :set_rdv_subject,
                :set_signature_lines, :set_rdv_title, :set_applicant_designation,
                :set_display_mandatory_warning, :set_display_punishable_warning,
                :set_rdv_purpose, :set_logo_path, :verify_phone_number_presence

  ### participation_created ###
  def presential_participation_created
    mail(
      to: @applicant.email,
      subject: "[Important - #{@rdv_subject.upcase}] Vous êtes #{@applicant.conjugate('convoqué')}" \
               " à un #{@rdv_title}"
    )
  end

  def by_phone_participation_created
    mail(
      to: @applicant.email,
      subject: "[Important - #{@rdv_subject.upcase}] Vous êtes #{@applicant.conjugate('convoqué')}" \
               " à un #{@rdv_title}"
    )
  end

  ### participation_updated ###
  def presential_participation_updated
    mail(
      to: @applicant.email,
      subject: "[Important - #{@rdv_subject.upcase}] Votre #{@rdv_title} a été modifié"
    )
  end

  def by_phone_participation_updated
    mail(
      to: @applicant.email,
      subject: "[Important - #{@rdv_subject.upcase}] Votre #{@rdv_title} a été modifié"
    )
  end

  ## participation_reminder ###

  def presential_participation_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel - #{@rdv_subject.upcase}] Vous êtes #{@applicant.conjugate('convoqué')}" \
               " à un #{@rdv_title}"
    )
  end

  def by_phone_participation_reminder
    mail(
      to: @applicant.email,
      subject: "[Rappel - #{@rdv_subject.upcase}] Vous êtes #{@applicant.conjugate('convoqué')}" \
               " à un #{@rdv_title}"
    )
  end

  ### participation_cancelled ###
  def participation_cancelled
    mail(
      to: @applicant.email,
      subject: "[Important - #{@rdv_subject.upcase}] Votre #{@rdv_title} a été annulé"
    )
  end

  private

  def set_notification
    @notification = params[:notification]
  end

  def set_applicant
    @applicant = @notification.applicant
  end

  def set_rdv
    @rdv = @notification.rdv
  end

  def set_department
    @department = @notification.department
  end

  def set_signature_lines
    @signature_lines = @notification.signature_lines
  end

  def set_rdv_title
    @rdv_title = rdv_by_phone? ? @notification.rdv_title_by_phone : @notification.rdv_title
  end

  def set_rdv_subject
    @rdv_subject = @notification.rdv_subject
  end

  def set_applicant_designation
    @applicant_designation = @notification.applicant_designation
  end

  def set_display_mandatory_warning
    @display_mandatory_warning = @notification.display_mandatory_warning
  end

  def set_display_punishable_warning
    @display_punishable_warning = @notification.display_punishable_warning
  end

  def set_rdv_purpose
    @rdv_purpose = @notification.rdv_purpose
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
