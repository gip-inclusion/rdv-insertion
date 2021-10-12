module FilterableApplicantsConcern
  def filter_applicants
    filter_applicants_by_search_query
    filter_applicants_by_action_required
    filter_applicants_by_status
    filter_applicants_by_page
  end

  def filter_applicants_by_status
    @applicants = @applicants.status(params[:status]) if params[:status].present?
  end

  def filter_applicants_by_action_required
    @applicants = @applicants.action_required if params[:action_required] == "true"
  end

  def filter_applicants_by_search_query
    @applicants = @applicants.search_by_text(params[:search_query]) if params[:search_query].present?
  end

  def filter_applicants_by_page
    @applicants = @applicants.page(page)
  end
end
