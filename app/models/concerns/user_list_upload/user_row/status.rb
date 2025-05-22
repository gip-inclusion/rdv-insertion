module UserListUpload::UserRow::Status
  def before_user_save_status
    if !matching_user_id
      user_valid? ? :to_create_with_no_errors : :to_create_with_errors
    elsif will_change_matching_user?
      user_valid? ? :to_update_with_no_errors : :to_update_with_errors
    else
      :up_to_date
    end
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
end
