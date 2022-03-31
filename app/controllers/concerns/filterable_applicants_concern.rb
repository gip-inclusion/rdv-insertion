module FilterableApplicantsConcern
  def filter_applicants
    filter_applicants_by_search_query
    filter_applicants_by_action_required
    filter_applicants_by_status
    filter_applicants_by_page
  end

  def filter_applicants_by_status
    @applicants = @applicants.active.status(params[:status]) if params[:status].present?
  end

  def filter_applicants_by_action_required
    @applicants = @applicants.action_required if params[:action_required] == "true"
  end

  def filter_applicants_by_search_query
    return if params[:search_query].blank?

    # with_pg_search_rank scope added to be compatible with distinct https://github.com/Casecommons/pg_search/issues/238
    @applicants = @applicants.search_by_text(params[:search_query]).with_pg_search_rank
  end

  def filter_applicants_by_page
    @applicants = @applicants.page(page)
  end
end
