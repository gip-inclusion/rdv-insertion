module ApplicantsHelper
  def format_date(date)
    date&.strftime("%d/%m/%Y")
  end

  def show_invitation?(department)
    !department.no_invitation?
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
      applicant.attention_needed? ? "bg-warning border-warning" : "text-white bg-danger border-danger"
    elsif applicant.rdv_seen?
      "text-white bg-success border-success"
    else
      ""
    end
  end
end
