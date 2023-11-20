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
    @users = @users.select(
      "users.*," \
      "(SELECT MAX(rdv_contexts.created_at) " \
      "FROM rdv_contexts WHERE rdv_contexts.user_id = users.id) AS affected_at"
    ).order("affected_at DESC, users.id DESC")
  end

  def all_users_order
    @users = @users.select(
      "users.*," \
      "(SELECT MAX(users_organisations.created_at) " \
      "FROM users_organisations WHERE users_organisations.user_id = users.id) AS affected_at" \
    ).order("affected_at DESC NULLS last, users.id DESC")
  end
end
