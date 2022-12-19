module FilterableApplicantsConcern
  private

  def filter_applicants
    filter_applicants_by_search_query
    filter_applicants_by_action_required
    filter_applicants_by_current_agent
    filter_applicants_by_status
    filter_applicants_by_first_invitations
    filter_applicants_by_last_invitations
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

  def filter_applicants_by_current_agent
    return unless params[:filter_by_current_agent] == "true"

    @applicants = @applicants.joins(:agents).where(agents: current_agent)
  end

  def filter_applicants_by_search_query
    return if params[:search_query].blank?

    # with_pg_search_rank scope added to be compatible with distinct https://github.com/Casecommons/pg_search/issues/238
    @applicants = @applicants.search_by_text(params[:search_query]).with_pg_search_rank
  end

  def filter_applicants_by_page
    return if request.format == "csv"

    @applicants = @applicants.page(page)
  end

  def filter_applicants_by_first_invitations
    return if [first_invitation_date_before, first_invitation_date_after].all?(&:blank?)

    relevant_invitations = invitations_belonging_to_rdv_contexts(applicants_first_invitations, @rdv_contexts)
    filter_applicants_by_invitation_dates(
      relevant_invitations, first_invitation_date_before, first_invitation_date_after
    )
  end

  def filter_applicants_by_last_invitations
    return if [last_invitation_date_before, last_invitation_date_after].all?(&:blank?)

    relevant_invitations = invitations_belonging_to_rdv_contexts(applicants_last_invitations, @rdv_contexts)
    filter_applicants_by_invitation_dates(
      relevant_invitations, last_invitation_date_before, last_invitation_date_after
    )
  end

  def filter_applicants_by_invitation_dates(invitations, invitation_date_before, invitation_date_after)
    filtered_invitations = invitations.select do |invitation|
      (invitation_date_before.blank? || invitation.sent_before?(invitation_date_before.to_date.end_of_day)) &&
        (invitation_date_after.blank? || invitation.sent_after?(invitation_date_after.to_date.beginning_of_day))
    end
    @applicants = @applicants.where(id: filtered_invitations.pluck(:applicant_id))
  end

  def first_invitation_date_before
    params[:first_invitation_date_before]
  end

  def first_invitation_date_after
    params[:first_invitation_date_after]
  end

  def last_invitation_date_before
    params[:last_invitation_date_before]
  end

  def last_invitation_date_after
    params[:last_invitation_date_after]
  end

  def applicants_first_invitations
    @applicants_first_invitations ||= @applicants.includes(:invitations, :rdvs)
                                                 .map(&:relevant_first_invitation)
                                                 .compact
  end

  def applicants_last_invitations
    @applicants_last_invitations ||= @applicants.includes(:invitations, :rdvs)
                                                .map(&:last_sent_invitation)
                                                .compact
  end

  def invitations_belonging_to_rdv_contexts(invitations, rdv_contexts)
    if rdv_contexts.blank?
      invitations
    else
      invitations.select { |i| rdv_contexts.include?(i.rdv_context) }
    end
  end
end
