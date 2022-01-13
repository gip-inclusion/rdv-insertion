module ApplicantsHelper
  def format_date(date)
    date&.strftime("%d/%m/%Y")
  end

  def show_sms_invitation?(configuration)
    configuration.sms? || configuration.sms_and_email?
  end

  def show_email_invitation?(configuration)
    configuration.email? || configuration.sms_and_email?
  end

  def show_notification?(configuration)
    configuration.notify_applicant?
  end

  def display_attribute(attribute)
    attribute.presence || " - "
  end

  def no_search_results?(applicants)
    applicants.empty? && params[:search_query].present?
  end

  def display_back_to_list_button?
    [params[:search_query], params[:status], params[:action_required]].any?(&:present?)
  end

  def options_for_select_status(statuses_count)
    statuses_count.map do |status, count|
      ["#{I18n.t("activerecord.attributes.applicant.statuses.#{status}")} (#{count})", status]
    end
  end

  def background_class_for_status(applicant)
    if applicant.action_required?
      applicant.attention_needed? ? "bg-warning border-warning" : "bg-danger border-danger"
    elsif applicant.rdv_seen? || applicant.resolved?
      "bg-success border-success"
    else
      ""
    end
  end

  def display_status_notice(applicant)
    if applicant.invited_before_time_window? && applicant.invitation_pending?
      " (Délai dépassé)"
    elsif applicant.multiple_rdvs_cancelled? && applicant.rdvs.last&.pending?
      " (RDV en attente)"
    elsif applicant.multiple_rdvs_cancelled?
      " (Courrier à envoyer)"
    else
      ""
    end
  end

  def rdv_solidarites_user_url(organisation, applicant)
    organisation_id = organisation.rdv_solidarites_organisation_id
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{organisation_id}/users/#{applicant.rdv_solidarites_user_id}"
  end

  def back_button_url_for_applicant_form(page_name, applicant, department, organisation)
    if page_name == "edit"
      return department_applicant_path(department, applicant) if params[:department_id].present?

      organisation_applicant_path(organisation, applicant)
    else
      return department_applicants_path(department) if params[:department_id].present?

      organisation_applicants_path(organisation)
    end
  end

  def back_button_url_for_show(department, organisation)
    return department_applicants_path(department) if params[:department_id].present?

    organisation_applicants_path(organisation)
  end

  def patch_applicant_url(department, organisation, applicant)
    return department_applicant_path(department, applicant) if params[:department_id].present?

    organisation_applicant_path(organisation, applicant)
  end
end
