class NotificationMailerError < StandardError; end

class NotificationMailer < ApplicationMailer
  before_action :set_applicant, :set_rdv, :set_department, :set_motif_category,
                :set_signature_lines, :set_boilerplate, :set_rdv_title,
                :set_display_mandatory_warning, :set_display_punishable_warning,
                :verify_phone_number_presence

  ### rdv_created ###
  def presential_rdv_created
    mail(
      to: @applicant.email,
      subject: "[Important] Vous êtes convoqué(e) à un #{@rdv_title} dans le cadre de votre RSA"
    )
  end

  def by_phone_rdv_created
    mail(
      to: @applicant.email,
      subject: "[Important] Vous êtes convoqué(e) à un #{@rdv_title} dans le cadre de votre RSA"
    )
  end

  ### rdv_updated ###
  def presential_rdv_updated
    mail(
      to: @applicant.email,
      subject: "[Important] Votre #{@rdv_title} dans le cadre de votre RSA a été modifié."
    )
  end

  def by_phone_rdv_updated
    mail(
      to: @applicant.email,
      subject: "[Important] Votre #{@rdv_title} dans le cadre de votre RSA a été modifié."
    )
  end

  ### rdv_cancelled ###
  def rdv_cancelled
    mail(
      to: @applicant.email,
      subject: "[Important] Votre #{@rdv_title} dans le cadre de votre RSA a été annulé."
    )
  end

  private

  def set_notification
    @notification = params[:notification]
  end

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
    @motif_category = params[:motif_category]
  end

  def set_boilerplate
    @boilerplate = MessagesBoilerplates.categories.send(:"#{@motif_category}")
  end

  def set_signature_lines
    @signature_lines = params[:signature_lines]
  end

  def set_rdv_title
    @rdv_title = rdv_by_phone? ? @boilerplate.rdv_title_by_phone : @boilerplate.rdv_title
    raise_missing_attribute("rdv_title#{rdv_by_phone? ? '_by_phone' : ''}") if @rdv_title.nil?
  end

  def set_display_mandatory_warning
    @display_mandatory_warning = @boilerplate.display_mandatory_warning
    raise_missing_attribute("display_mandatory_warning") if @display_mandatory_warning.nil?
  end

  def set_display_punishable_warning
    @display_punishable_warning = @boilerplate.display_punishable_warning
    raise_missing_attribute("display_punishable_warning") if @display_punishable_warning.nil?
  end

  def rdv_by_phone?
    action_name.include?("by_phone")
  end

  def verify_phone_number_presence
    # if we send a notif for a phone rdv we want to be sure the applicant has a phone
    return unless rdv_by_phone?
    return if @applicant.phone_number_is_mobile?

    raise(
      NotificationMailerError,
      "No valid phone found for applicant #{@applicant.id}, cannot notify him by phone"
    )
  end

  def raise_for_missing_attribute(attribute)
    raise NotificationMailerError, "#{attribute} not found for #{@motif_category}"
  end
end
