module FilterableApplicantsConcern
  def filter_applicants
    filter_applicants_by_search_query
    filter_applicants_by_action_required
    filter_applicants_by_status
    filter_applicants_by_first_invitation_before
    filter_applicants_by_first_invitation_after
    filter_applicants_by_last_invitation_before
    filter_applicants_by_last_invitation_after
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

  def filter_applicants_by_first_invitation_before
    return if params[:first_invitation_date_before].blank?

    applicants_first_invitations = @applicants.includes(:invitations, :rdvs)
                                              .collect(&:relevant_first_invitation)
                                              .compact
    relevant_first_invitations = applicants_first_invitations.to_a.select do |invitation|
      invitation.sent_at > params[:first_invitation_date_before]
    end
    @applicants = @applicants.where(id: relevant_first_invitations.pluck(:applicant_id))
  end

  def filter_applicants_by_first_invitation_after
    return if params[:first_invitation_date_after].blank?

    applicants_first_invitations = @applicants.includes(:invitations, :rdvs)
                                              .collect(&:relevant_first_invitation)
                                              .compact
    relevant_first_invitations = applicants_first_invitations.to_a.select do |invitation|
      invitation.sent_at < params[:first_invitation_date_after]
    end
    @applicants = @applicants.where(id: relevant_first_invitations.pluck(:applicant_id))
  end

  def filter_applicants_by_last_invitation_before
    return if params[:last_invitation_date_before].blank?

    applicants_last_invitations = @applicants.includes(:invitations, :rdvs)
                                             .collect(&:last_sent_invitation)
                                             .compact
    relevant_last_invitations = applicants_last_invitations.to_a.select do |invitation|
      invitation.sent_at > params[:last_invitation_date_before]
    end
    @applicants = @applicants.where(id: relevant_last_invitations.pluck(:applicant_id))
  end

  def filter_applicants_by_last_invitation_after
    return if params[:last_invitation_date_after].blank?

    applicants_last_invitations = @applicants.includes(:invitations, :rdvs)
                                             .collect(&:last_sent_invitation)
                                             .compact
    relevant_last_invitations = applicants_last_invitations.to_a.select do |invitation|
      invitation.sent_at < params[:last_invitation_date_after]
    end
    @applicants = @applicants.where(id: relevant_last_invitations.pluck(:applicant_id))
  end

  def filter_applicants_by_page
    return if request.format == "csv"

    @applicants = @applicants.page(page)
  end
end
