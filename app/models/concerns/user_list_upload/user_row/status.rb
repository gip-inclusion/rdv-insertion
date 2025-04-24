module UserListUpload::UserRow::Status
  def before_user_save_status
    return determine_create_status unless matching_user_id
    # The evaluation order is important here: user_valid? must be evaluated before will_change_matching_user?
    # to ensure consistent results during sorting
    if (user_valid? && will_change_matching_user?) || (!user_valid? && will_change_matching_user?)
      return determine_update_status
    end

    :up_to_date
  end

  def after_user_save_status
    return :pending unless attempted_user_save?
    return :organisation_needs_to_be_assigned if last_user_save_attempt.no_organisation_to_assign?
    return :error unless last_user_save_attempt.success?

    {
      to_create: :created,
      to_create_with_no_errors: :created,
      to_update: :updated,
      to_update_with_no_errors: :updated,
      up_to_date: :updated
    }[before_user_save_status]
  end

  def before_invitation_status
    return :already_invited if previously_invited?

    :not_invited
  end

  def after_invitation_status
    return :pending unless invitation_attempted?

    if all_invitations_failed?
      :error
    else
      :invited
    end
  end

  private

  def determine_create_status
    user_valid? ? :to_create_with_no_errors : :to_create_with_errors
  end

  def determine_update_status
    user_valid? ? :to_update_with_no_errors : :to_update_with_errors
  end
end
