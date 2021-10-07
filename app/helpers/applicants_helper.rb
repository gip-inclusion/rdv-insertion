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
    params[:search_query].present?
  end

  def background_class_for_status(status)
    if status.in?(%w[not_invited rdv_needs_status_update rdv_noshow rdv_revoked rdv_excused])
      "text-white bg-danger border-danger"
    elsif status.in?(%w[invitation_pending rdv_creation_pending])
      "bg-warning border-warning"
    elsif status.in?(%w[rdv_seen])
      "text-white bg-success border-success"
    else
      ""
    end
  end
end
