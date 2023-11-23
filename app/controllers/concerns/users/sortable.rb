module Users::Sortable
  def order_users
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
    @users = @users.select("users.*, rdv_contexts.created_at")
                   .order("rdv_contexts.created_at desc")
  end

  def all_users_order
    @users = @users.select("users.*, MIN(users_organisations.created_at) AS min_created_at")
                   .group("users.id")
                   .order("min_created_at DESC")
  end
end
