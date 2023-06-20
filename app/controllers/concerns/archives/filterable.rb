module Archives::Filterable
  extend ActiveSupport::Concern

  private

  def filter_archives
    filter_archives_by_search_query
    filter_archives_by_current_agent
    filter_archives_by_applicant_creation_date_after
    filter_archives_by_applicant_creation_date_before
    filter_archives_by_archiving_date_after
    filter_archives_by_archiving_date_before
    filter_archives_by_page
  end

  def filter_archives_by_search_query
    return if params[:search_query].blank?

    @archives = @archives.where(applicant: @applicants.search_by_text(params[:search_query]).pluck(:id))
  end

  def filter_archives_by_current_agent
    return unless params[:filter_by_current_agent] == "true"

    @archives = @archives.where(applicant: @applicants.joins(:referents).where(referents: { id: current_agent.id }))
  end

  def filter_archives_by_applicant_creation_date_after
    return if params[:applicants_creation_date_after].blank?

    @archives = @archives
                .where(
                  applicant:
                    @applicants.where(
                      "applicants.created_at > ?", params[:applicants_creation_date_after].to_date.end_of_day
                    )
                )
  end

  def filter_archives_by_applicant_creation_date_before
    return if params[:applicants_creation_date_before].blank?

    @archives = @archives
                .where(
                  applicant:
                    @applicants.where(
                      "applicants.created_at < ?", params[:applicants_creation_date_before].to_date.end_of_day
                    )
                )
  end

  def filter_archives_by_archiving_date_after
    return if params[:archiving_date_after].blank?

    @archives = @archives.where("archives.created_at > ?", params[:archiving_date_after].to_date.end_of_day)
  end

  def filter_archives_by_archiving_date_before
    return if params[:archiving_date_before].blank?

    @archives = @archives.where("archives.created_at < ?", params[:archiving_date_before].to_date.end_of_day)
  end

  def filter_archives_by_page
    return if request.format == "csv"

    @archives = @archives.page(page)
  end
end
