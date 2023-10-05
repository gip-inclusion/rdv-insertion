module Users::Sortable
  def order_users
    return if params[:search_query].present?

    if archived_scope?
      archived_order
    elsif @current_motif_category
      motif_category_order
    else
      all_users_order
    end
  end

  def archived_order
    @users = @users.order("archives.created_at desc")
  end

  def motif_category_order
    @users = if %w[first_invitation_sent_at last_invitation_sent_at].include?(params[:sort_by]) && params[:sort_order]
               first_or_last = sort_order_from_params == "up" ? "MIN" : "MAX"

               @users
                 .left_joins(rdv_contexts: :invitations)
                 .reselect("DISTINCT(users.id), users.*, #{first_or_last}(invitations.sent_at) as relevant_invitation")
                 .group("users.id")
                 .order("relevant_invitation #{sort_order_from_params} NULLS LAST")
             else
               @users
                 .select("DISTINCT(users.id), users.*, rdv_contexts.created_at")
                 .order("rdv_contexts.created_at #{sort_order_from_params}")
             end
  end

  def all_users_order
    if department_level?
      associated_users_organisations = UsersOrganisation
                                       .where(organisations: @organisations)
                                       .order(created_at: :desc)
                                       .uniq(&:user_id)
                                       .map(&:id)

      users_affected_most_recently_to_an_organisation = {
        users_organisations: {
          id: associated_users_organisations
        }
      }
    end

    @users = @users.includes(:users_organisations, :archives)
                   .select("
                                DISTINCT(users.id),
                                users.*,
                                users_organisations.created_at as affected_at
                              ")
                   .active
                   .where(users_affected_most_recently_to_an_organisation || {})
                   .order("affected_at DESC NULLS LAST, users.id DESC")
  end

  def sort_order_from_params
    params[:sort_order] == "up" ? "asc" : "desc"
  end
end
