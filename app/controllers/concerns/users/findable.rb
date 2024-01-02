module Users::Findable
  def set_all_configurations
    @all_configurations =
      policy_scope(::Configuration).joins(:organisation)
                                   .includes(:motif_category)
                                   .where(current_organisation_filter)
                                   .uniq(&:motif_category_id)

    @all_configurations =
      department_level? ? @all_configurations.sort_by(&:department_position) : @all_configurations.sort_by(&:position)
  end

  def set_current_configuration
    return if archived_scope?
    return unless params[:motif_category_id]

    @current_configuration =
      @all_configurations.find { |c| c.motif_category_id == params[:motif_category_id].to_i }
  end

  def set_current_motif_category
    @current_motif_category = @current_configuration&.motif_category
  end

  def set_users
    if archived_scope?
      set_archived_users
    elsif @current_motif_category
      set_users_for_motif_category
    else
      set_all_users
    end
  end

  def set_all_users
    @users = policy_scope(User)
             .active.distinct
             .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
    return if request.format == "csv"

    @users = @users.preload(:archives, rdv_contexts: [:invitations])
  end

  def set_users_for_motif_category
    @users = policy_scope(User)
             .preload(:organisations, rdv_contexts: [:notifications, :invitations])
             .active.distinct
             .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
             .where.not(id: @department.archived_users.ids)
             .joins(:rdv_contexts)
             .where(rdv_contexts: { motif_category: @current_motif_category })
             .where.not(rdv_contexts: { status: "closed" })
  end

  def set_archived_users
    @users = policy_scope(User)
             .includes(:archives)
             .preload(:invitations, :participations)
             .active.distinct
             .where(id: @department.archived_users)
             .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
  end

  def archived_scope?
    @users_scope == "archived"
  end

  def set_users_scope
    @users_scope = params[:users_scope]
  end
end
