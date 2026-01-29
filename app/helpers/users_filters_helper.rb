module UsersFiltersHelper
  def filter_list
    [
      :search_query,
      :tag_ids,
      :follow_up_statuses,
      :orientation_type_ids,
      :action_required,
      :referent_ids,
      :creation_date_after,
      :creation_date_before,
      :convocation_date_before,
      :convocation_date_after,
      :first_invitation_date_before,
      :first_invitation_date_after,
      :last_invitation_date_before,
      :last_invitation_date_after
    ]
  end

  def active_filter_list
    filter_list.select { |filter| params[filter].present? }
  end

  def invitation_or_convocation_active_filters_count
    active_filters_count = 0

    active_filters_count += 1 if params[:convocation_date_after].present? || params[:convocation_date_before].present?

    if params[:first_invitation_date_after].present? || params[:first_invitation_date_before].present?
      active_filters_count += 1
    end

    if params[:last_invitation_date_after].present? || params[:last_invitation_date_before].present?
      active_filters_count += 1
    end

    active_filters_count
  end

  def any_active_invitation_or_convocation_filters?
    params[:convocation_date_after].present? ||
      params[:convocation_date_before].present? ||
      params[:first_invitation_date_after].present? ||
      params[:first_invitation_date_before].present? ||
      params[:last_invitation_date_after].present? ||
      params[:last_invitation_date_before].present?
  end
end
