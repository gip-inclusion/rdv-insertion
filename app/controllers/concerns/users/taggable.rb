module Users::Taggable
  private

  def set_user_tags
    @user_tags = policy_scope(@user.tags)
                 .joins(:organisations)
                 .preload(:tag_users)
                 .where(current_organisations_filter)
                 .order(Arel.sql("LOWER(tags.value)"))
                 .group("tags.id")
  end
end
