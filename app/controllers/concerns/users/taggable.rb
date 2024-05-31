module Users::Taggable
  private

  def set_filterable_tags
    @tags = policy_scope((@organisation || @department).tags).order(Arel.sql("LOWER(tags.value)")).group("tags.id")
  end

  def set_user_tags
    @user_tags = policy_scope(@user.tags)
                 .joins(:organisations)
                 .where(current_organisations_filter)
                 .order(Arel.sql("LOWER(tags.value)"))
                 .group("tags.id")
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

  def set_available_tags
    @available_tags =
      if department_level?
        policy_scope(department.tags).order(Arel.sql("LOWER(tags.value)")).group("tags.id")
      else
        organisation.tags.order(Arel.sql("LOWER(tags.value)"))
      end
  end
end
