module ApplicantsHelper
  def format_date(date)
    date&.strftime("%d/%m/%Y")
  end

  def show_invitation?(department)
    !department.no_invitation?
  end

  def show_notification?(department)
    department.notify_applicant?
  end

  def display_attribute(attribute)
    attribute || " - "
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
    elsif applicant.rdv_seen?
      "text-white bg-success border-success"
    else
      ""
    end
  end

  def bg_for_account_creation(applicant)
    applicant.created_at ? "" : "bg-danger"
  end

  def bg_for_invitation_date(applicant, format)
    date = get_invitation_date(applicant, format)

    if applicant.invited_before_time_window? && date
      "bg-warning"
    elsif date && applicant.rdvs.empty?
      "bg-success"
    elsif !applicant.last_email_invitation_sent_at && !applicant.last_sms_invitation_sent_at
      "bg-danger"
    end
  end

  def get_invitation_date(applicant, format)
    if format == "sms"
      applicant.last_sms_invitation_sent_at
    else
      applicant.last_email_invitation_sent_at
    end
  end

  def display_notice(applicant)
    applicant.invited_before_time_window? ? " (Délai dépassé)" : ""
  end

  def account_creation_date(applicant)
    applicant.created_at ? format_date(applicant.created_at) : "-"
  end

  def class_for_account_creation_button(applicant)
    applicant.created_at ? "disabled" : ""
  end

  def last_sms_invitation_date(applicant)
    applicant.last_sms_invitation_sent_at ? format_date(applicant.last_sms_invitation_sent_at) : "-"
  end

  def last_email_invitation_date(applicant)
    applicant.last_email_invitation_sent_at ? format_date(applicant.last_email_invitation_sent_at) : "-"
  end

  def class_for_invitation_button(applicant)
    applicant.rdvs.any? && !applicant.action_required? ? "disabled" : ""
  end

  def text_for_invitation_button(applicant, format)
    date = get_invitation_date(applicant, format)
    date ? "Relancer" : "Inviter"
  end

  def last_rdv_creation_date(applicant)
    applicant.rdvs.last ? applicant.rdvs.last.created_at : "-"
  end

  def last_rdv_date(applicant)
    applicant.rdvs.last ? applicant.rdvs.last&.formatted_start_date : "-"
  end
end
