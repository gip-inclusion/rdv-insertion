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
    @user = @users.order("archives.created_at desc")
  end

  def motif_category_order
    @users = @users.select("users.*, rdv_contexts.created_at")
                   .order("rdv_contexts.created_at desc")
  end

  def all_users_order
    @users = @users.select("users.*, users_organisations.created_at")
                   .order("users_organisations.created_at DESC NULLS LAST, users.id DESC")
  end
end
