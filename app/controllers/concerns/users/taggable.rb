module Users::Taggable
  private

  def set_filterable_tags
    @tags = policy_scope((@organisation || @department).tags).order(:value).distinct
  end

  def set_user_tags
    @user_tags = policy_scope(@user.tags)
                 .joins(:organisations)
                 .where(current_organisations_filter)
                 .order(:value)
                 .distinct
  end

  def reset_tag_users
    return unless user_params[:tag_users_attributes]

    @user
      .tags
      .joins(:organisations)
      .where(organisations: department_level? ? @department.organisations : @organisation)
      .find_each do |tag|
      @user.tags.delete(tag)
    end
  end
end
