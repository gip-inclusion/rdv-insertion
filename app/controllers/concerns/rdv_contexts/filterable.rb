module RdvContexts::Filterable
  extend ActiveSupport::Concern

  private

  def filter_rdv_contexts
    filter_rdv_contexts_by_search_query
    filter_rdv_contexts_by_current_agent
    filter_rdv_contexts_by_action_required
    filter_rdv_contexts_by_status
    filter_rdv_contexts_by_first_invitation_date_after
    filter_rdv_contexts_by_first_invitation_date_before
    filter_rdv_contexts_by_last_invitation_date_after
    filter_rdv_contexts_by_last_invitation_date_before
    filter_rdv_contexts_by_page
  end

  def filter_rdv_contexts_by_search_query
    return if params[:search_query].blank?

    @rdv_contexts =
      @rdv_contexts.where(applicant: @applicants.search_by_text(params[:search_query]).pluck(:id))
  end

  def filter_rdv_contexts_by_current_agent
    return unless params[:filter_by_current_agent] == "true"

    @rdv_contexts =
      @rdv_contexts.where(applicant: @applicants.joins(:referents).where(referents: { id: current_agent.id }))
  end

  def filter_rdv_contexts_by_action_required
    return unless params[:action_required] == "true"

    @rdv_contexts = @rdv_contexts.action_required(@current_configuration.number_of_days_before_action_required)
  end

  def filter_rdv_contexts_by_status
    return if params[:status].blank?

    @rdv_contexts = @rdv_contexts.status(params[:status])
  end

  def filter_rdv_contexts_by_first_invitation_date_after
    return if params[:first_invitation_date_after].blank?

    relevant_invitations =
      @rdv_contexts.includes(:invitations).map(&:first_sent_invitation).compact
                   .select do |invitation|
                     invitation.sent_after?(params[:first_invitation_date_after].to_date.end_of_day)
                   end
    @rdv_contexts = @rdv_contexts.where(id: relevant_invitations.pluck(:rdv_context_id))
  end

  def filter_rdv_contexts_by_first_invitation_date_before
    return if params[:first_invitation_date_before].blank?

    relevant_invitations =
      @rdv_contexts.includes(:invitations).map(&:first_sent_invitation).compact
                   .select do |invitation|
                     invitation.sent_before?(params[:first_invitation_date_before].to_date.end_of_day)
                   end
    @rdv_contexts = @rdv_contexts.where(id: relevant_invitations.pluck(:rdv_context_id))
  end

  def filter_rdv_contexts_by_last_invitation_date_after
    return if params[:last_invitation_date_after].blank?

    relevant_invitations =
      @rdv_contexts.includes(:invitations).map(&:last_sent_invitation).compact
                   .select do |invitation|
                     invitation.sent_after?(params[:last_invitation_date_after].to_date.end_of_day)
                   end
    @rdv_contexts = @rdv_contexts.where(id: relevant_invitations.pluck(:rdv_context_id))
  end

  def filter_rdv_contexts_by_last_invitation_date_before
    return if params[:last_invitation_date_before].blank?

    relevant_invitations =
      @rdv_contexts.includes(:invitations).map(&:last_sent_invitation).compact
                   .select do |invitation|
                     invitation.sent_before?(params[:last_invitation_date_before].to_date.end_of_day)
                   end
    @rdv_contexts = @rdv_contexts.where(id: relevant_invitations.pluck(:rdv_context_id))
  end

  def filter_rdv_contexts_by_page
    return if request.format == "csv"

    @rdv_contexts = @rdv_contexts.page(page)
  end
end
