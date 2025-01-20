module UserListUpload::UserRow::MatchingUser
  private

  def set_matching_user
    return if matching_user_id.present?

    matching_user = find_matching_user
    self.matching_user_id = matching_user.id if matching_user
  end

  def find_matching_user
    find_matching_user_in_all_app || find_matching_user_in_department
  end

  def find_matching_user_in_all_app
    potential_matching_users_in_all_app.find do |matching_user|
      user_matches_nir?(matching_user.nir) ||
        user_matches_phone_number?(matching_user) ||
        user_matches_email?(matching_user)
    end
  end

  def find_matching_user_in_department
    potential_matching_users_in_department.find do |matching_user|
      user_matches_department_internal_id?(matching_user) ||
        user_matches_affiliation_number_and_role?(matching_user)
    end
  end

  def user_matches_nir?(matching_user_nir)
    nir.present? && matching_user_nir.present? && NirHelper.equal?(nir, matching_user_nir)
  end

  def user_matches_phone_number?(matching_user)
    phone_number.present? && matching_user.phone_number.present? &&
      first_name.present? && matching_user.first_name.present? &&
      matching_user.first_name.split.first.downcase == first_name.split.first.downcase &&
      matching_user.phone_number == phone_number
  end

  def user_matches_department_internal_id?(matching_user)
    department_internal_id.present? && matching_user.department_internal_id.present? &&
      matching_user.department_internal_id == department_internal_id
  end

  def user_matches_affiliation_number_and_role?(matching_user)
    affiliation_number.present? && matching_user.affiliation_number.present? &&
      role.present? && matching_user.role.present? &&
      matching_user.affiliation_number == affiliation_number &&
      matching_user.role == role
  end

  def user_matches_email?(matching_user)
    email.present? && matching_user.email.present? &&
      first_name.present? && matching_user.first_name.present? &&
      matching_user.first_name.split.first.downcase == first_name.split.first.downcase &&
      matching_user.email == email
  end

  def potential_matching_users_in_all_app
    if persisted?
      retrieve_potential_matching_users_in_all_app
    else
      # user_row is always created with the other user_list_upload user_rows
      # so on creation we retrieve the user_list_upload potential matching users to not
      # trigger a new query in each user_row creation when creating the user_list_upload
      user_list_upload.potential_matching_users_in_all_app
    end
  end

  def potential_matching_users_in_department
    if persisted?
      retrieve_potential_matching_users_in_department
    else
      # user_row is always created with the other user_list_upload user_rows
      # so on creation we retrieve the user_list_upload potential matching users to not
      # trigger a new query in each user_row creation when creating the user_list_upload
      user_list_upload.potential_matching_users_in_department
    end
  end

  def retrieve_potential_matching_users_in_all_app
    User.where(email: email).or(User.where(phone_number: phone_number)).or(User.where(nir: nir))
  end

  def retrieve_potential_matching_users_in_department
    User.joins(:organisations).where(
      affiliation_number: affiliation_number,
      organisations: { department_id: department.id }
    ).or(
      User.joins(:organisations).where(
        department_internal_id: department_internal_id,
        organisations: { department_id: department.id }
      )
    )
  end
end
