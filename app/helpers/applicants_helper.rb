module ApplicantsHelper
  def format_date(date)
    date&.strftime("%d/%m/%Y")
  end

  def show_sms_invitation?(configuration)
    configuration.invitation_formats.include?("sms")
  end

  def show_email_invitation?(configuration)
    configuration.invitation_formats.include?("email")
  end

  def show_postal_invitation?(configuration)
    configuration.invitation_formats.include?("postal")
  end

  def show_notification?(configuration)
    configuration.notify_applicant?
  end

  def show_invitations?(configuration)
    configuration.invitation_formats.present?
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

  def background_class_for_context_status(context, number_of_days_before_action_required)
    return "" if context.nil?

    if context.action_required?(number_of_days_before_action_required)
      context.attention_needed? ? "bg-warning border-warning" : "bg-danger border-danger"
    elsif context.rdv_seen?
      "bg-success border-success"
    else
      ""
    end
  end

  def background_class_for_rdv_status(rdv)
    if rdv.seen?
      "bg-success border-success"
    elsif rdv.cancelled?
      "bg-danger border-danger"
    elsif rdv.needs_status_update?
      "bg-warning border-warning"
    else
      ""
    end
  end

  def display_context_status(context, number_of_days_before_action_required)
    return "Non rattaché" if context.nil?

    I18n.t("activerecord.attributes.rdv_context.statuses.#{context.status}") +
      display_context_status_notice(context, number_of_days_before_action_required)
  end

  def display_rdv_status(rdv)
    rdv.pending? ? "À venir" : I18n.t("activerecord.attributes.rdv.statuses.#{rdv.status}")
  end

  def display_context_status_notice(context, number_of_days_before_action_required)
    if context.invited_before_time_window?(number_of_days_before_action_required) && context.invitation_pending?
      " (Délai dépassé)"
    else
      ""
    end
  end

  def rdv_solidarites_user_url(organisation, applicant)
    organisation_id = organisation.rdv_solidarites_organisation_id
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{organisation_id}/users/#{applicant.rdv_solidarites_user_id}"
  end

  def department_level?
    params[:department_id].present?
  end

  def compute_index_path(organisation, department, **params)
    if department_level?
      department_applicants_path(department, **params)
    else
      organisation_applicants_path(organisation, **params)
    end
  end

  def compute_edit_path(applicant, organisation, department)
    return edit_department_applicant_path(department, applicant) if department_level?

    edit_organisation_applicant_path(organisation, applicant)
  end

  def compute_applicant_path(applicant, organisation, department)
    return department_applicant_path(department, applicant) if department_level?

    organisation_applicant_path(organisation, applicant)
  end
end
