module Users
  # rubocop:disable Metrics/ClassLength
  class FilterList
    attr_reader :params, :users, :scoped_user_class, :format, :page, :rdv_contexts

    def initialize(params:, page:, format: "html", scoped_user_class: User)
      @params = params
      @scoped_user_class = scoped_user_class
      @format = format
      @page = page
    end

    def perform
      set_users
      set_rdv_contexts
      filter_users
      sort_users

      self
    end

    def current_configuration
      return if archived_scope?
      return unless params[:motif_category_id]

      @current_configuration ||=
        @all_configurations.find { |c| c.motif_category_id == params[:motif_category_id].to_i }
    end

    def current_motif_category
      @current_motif_category ||= current_configuration&.motif_category
    end

    def set_rdv_contexts
      return if archived_scope?

      @rdv_contexts = RdvContext.where(
        user_id: @users.ids, motif_category: current_motif_category
      )
    end

    private

    def sort_users
      @users = SortList.new(users:, params:).perform
    end

    def scope
      params[:users_scope]
    end

    def archived_scope?
      params[:users_scope] == "archived"
    end

    def set_users
      if scope == "archived"
        set_archived_users
      elsif scope == "motif_category"
        set_users_for_motif_category
      else
        set_all_users
      end
    end

    def set_all_users
      @users = scoped_user_class
               .active.distinct
               .where(Current.organisations_filter)
      return if format == "csv"

      @users = @users.preload(:archives, rdv_contexts: [:invitations])
    end

    def set_users_for_motif_category
      @users = scoped_user_class
               .preload(:organisations, rdv_contexts: [:notifications, :invitations])
               .active.distinct
               .where(Current.organisations_filter)
               .where.not(id: Current.department.archived_users.ids)
               .joins(:rdv_contexts)
               .where(rdv_contexts: { motif_category: current_motif_category })
               .where.not(rdv_contexts: { status: "closed" })
    end

    def set_archived_users
      @users = scoped_user_class
               .includes(:archives)
               .preload(:invitations, :participations)
               .active.distinct
               .where(id: Current.department.archived_users)
               .where(department_level? ? { organisations: } : { organisations: organisation })
    end

    def filter_users
      filter_users_by_search_query
      filter_users_by_action_required
      filter_users_by_current_agent
      filter_users_by_status
      filter_users_by_creation_date_after
      filter_users_by_creation_date_before
      filter_users_by_first_invitations
      filter_users_by_last_invitations
      filter_users_by_page
      filter_users_by_tags
    end

    def filter_users_by_tags
      return if params[:tag_ids].blank?

      user_ids = TagUser
                 .select(:user_id)
                 .where(tag_id: params[:tag_ids])
                 .group(:user_id)
                 .having("COUNT(DISTINCT tag_id) = ?", [params[:tag_ids]].flatten.count)
                 .pluck(:user_id)

      @users = @users.where(id: user_ids)
    end

    def filter_users_by_status
      return if params[:status].blank?

      @users = @users.joins(:rdv_contexts).where(rdv_contexts: rdv_contexts.status(params[:status]))
    end

    def filter_users_by_action_required
      return unless params[:action_required] == "true"

      @users = @users.joins(:rdv_contexts).where(
        rdv_contexts: rdv_contexts.action_required(@current_configuration.number_of_days_before_action_required)
      )
    end

    def filter_users_by_current_agent
      return unless params[:filter_by_current_agent] == "true"

      @users = @users.joins(:referents).where(referents: { id: current_agent.id })
    end

    def filter_users_by_search_query
      return if params[:search_query].blank?

      # reorder is necessary to use distinct and ordering https://github.com/Casecommons/pg_search/issues/238#issuecomment-543702501
      @users = @users.search_by_text(params[:search_query]).reorder("")
    end

    def filter_users_by_page
      return if format == "csv"

      @users = @users.page(page)
    end

    def filter_users_by_creation_date_after
      return if params[:creation_date_after].blank?

      @users = @users.where("users.created_at > ?", params[:creation_date_after].to_date.end_of_day)
    end

    def filter_users_by_creation_date_before
      return if params[:creation_date_before].blank?

      @users = @users.where("users.created_at < ?", params[:creation_date_before].to_date.end_of_day)
    end

    def filter_users_by_first_invitations
      return if [first_invitation_date_before, first_invitation_date_after].all?(&:blank?)

      relevant_invitations = invitations_belonging_to_rdv_contexts(users_first_invitations, rdv_contexts)
      filter_users_by_invitation_dates(
        relevant_invitations, first_invitation_date_before, first_invitation_date_after
      )
    end

    def filter_users_by_last_invitations
      return if [last_invitation_date_before, last_invitation_date_after].all?(&:blank?)

      relevant_invitations = invitations_belonging_to_rdv_contexts(users_last_invitations, rdv_contexts)
      filter_users_by_invitation_dates(
        relevant_invitations, last_invitation_date_before, last_invitation_date_after
      )
    end

    def filter_users_by_invitation_dates(invitations, invitation_date_before, invitation_date_after)
      filtered_invitations = invitations.select do |invitation|
        (invitation_date_before.blank? || invitation.sent_before?(invitation_date_before.to_date.end_of_day)) &&
          (invitation_date_after.blank? || invitation.sent_after?(invitation_date_after.to_date.beginning_of_day))
      end
      @users = @users.where(id: filtered_invitations.pluck(:user_id))
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

    def users_first_invitations
      @users_first_invitations ||= @users.includes(:invitations, :rdvs)
                                         .map(&:first_sent_invitation)
                                         .compact
    end

    def users_last_invitations
      @users_last_invitations ||= @users.includes(:invitations, :rdvs)
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
  # rubocop:enable Metrics/ClassLength
end
