module Applicants::Filterable
  private

  def filter_applicants
    filter_applicants_by_search_query
    filter_applicants_by_current_agent
    filter_applicants_by_creation_date_after
    filter_applicants_by_creation_date_before
    filter_applicants_by_page
  end

  def filter_applicants_by_search_query
    return if params[:search_query].blank?

    # with_pg_search_rank scope added to be compatible with distinct https://github.com/Casecommons/pg_search/issues/238
    @applicants = @applicants.search_by_text(params[:search_query]).with_pg_search_rank
  end

  def filter_applicants_by_current_agent
    return unless params[:filter_by_current_agent] == "true"

    @applicants = @applicants.joins(:referents).where(referents: { id: current_agent.id })
  end

  def filter_applicants_by_creation_date_after
    return if params[:applicants_creation_date_after].blank?

    @applicants = @applicants
                  .where("applicants.created_at > ?", params[:applicants_creation_date_after].to_date.end_of_day)
  end

  def filter_applicants_by_creation_date_before
    return if params[:applicants_creation_date_before].blank?

    @applicants = @applicants
                  .where("applicants.created_at < ?", params[:applicants_creation_date_before].to_date.end_of_day)
  end

  def filter_applicants_by_page
    return if request.format == "csv"

    @applicants = @applicants.page(page)
  end
end
