module FilterableApplicantsConcern
  def filter_applicants
    filter_applicants_by_search_query
    filter_applicants_by_action_required
    filter_applicants_by_status
    filter_applicant_by_invitations_dates
    filter_applicants_by_page
  end

  def filter_applicants_by_status
    return if params[:status].blank?

    @applicants = @applicants.joins(:rdv_contexts).where(rdv_contexts: @rdv_contexts.status(params[:status]))
  end

  def filter_applicants_by_action_required
    return unless params[:action_required] == "true"

    @applicants = @applicants.joins(:rdv_contexts).where(
      rdv_contexts: @rdv_contexts.action_required(@current_configuration.number_of_days_before_action_required)
    )
  end

  def filter_applicants_by_search_query
    return if params[:search_query].blank?

    # with_pg_search_rank scope added to be compatible with distinct https://github.com/Casecommons/pg_search/issues/238
    @applicants = @applicants.search_by_text(params[:search_query]).with_pg_search_rank
  end

  def filter_applicant_by_invitations_dates
    invitations_dates_params_names = %w[
      first_invitation_date_before last_invitation_date_before first_invitation_date_after last_invitation_date_after
    ]

    invitations_dates_params_names.each do |param_name|
      next if params[param_name].blank?

      invitation_type = param_name.split("_").first
      comparison_type = param_name.split("_").last
      filter_applicants_by_invitation_date(invitation_type, comparison_type, params[param_name])
    end
  end

  def filter_applicants_by_invitation_date(invitation_type, comparison_type, param)
    concerned_invitations = invitation_type == "first" ? :relevant_first_invitation : :last_sent_invitation

    applicants_concerned_invitations = @applicants.includes(:invitations, :rdvs)
                                                  .map(&concerned_invitations)
                                                  .compact
    relevant_invitations = if comparison_type == "before"
                             compare_invitations_dates_before(applicants_concerned_invitations, param)
                           else
                             compare_invitations_dates_after(applicants_concerned_invitations, param)
                           end
    @applicants = @applicants.where(id: relevant_invitations.pluck(:applicant_id))
  end

  def compare_invitations_dates_before(invitations, param_date)
    invitations.select do |invitation|
      invitation.sent_at > param_date && invitation.rdv_context_id.in?(@rdv_contexts.map(&:id))
    end
  end

  def compare_invitations_dates_after(invitations, param_date)
    invitations.select do |invitation|
      invitation.sent_at < param_date && invitation.rdv_context_id.in?(@rdv_contexts.map(&:id))
    end
  end

  def filter_applicants_by_page
    return if request.format == "csv"

    @applicants = @applicants.page(page)
  end
end
