module UserListUpload::UserRow::MatchingUser
  private

  def set_matching_user
    return if matching_user_id.present?
    return if user_save_succeeded?

    matching_user = find_matching_user
    self.matching_user_id = matching_user.id if matching_user
  end

  def find_matching_user
    all_app_users = potential_matching_users_in_all_app
    department_users = potential_matching_users_in_department

    find_user_by_nir(all_app_users) ||
      find_user_by_department_internal_id(department_users) ||
      find_user_by_email(all_app_users) ||
      find_user_by_phone_number(all_app_users) ||
      find_user_by_affiliation_number_and_role(department_users)
  end

  def find_user_by_nir(users)
    users.find { |user| user_matches_nir?(user.nir) }
  end

  def find_user_by_department_internal_id(users)
    users.find { |user| user_matches_department_internal_id?(user) }
  end

  def find_user_by_email(users)
    users.find { |user| user_matches_email?(user) }
  end

  def find_user_by_phone_number(users)
    users.find { |user| user_matches_phone_number?(user) }
  end

  def find_user_by_affiliation_number_and_role(users)
    users.find { |user| user_matches_affiliation_number_and_role?(user) }
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
      # when user_row is not persisted, we retrieve the potential matching users at the
      # user_list_upload level to not trigger a new query in each user_row creation
      user_list_upload.potential_matching_users_in_all_app
    end
  end

  def potential_matching_users_in_department
    if persisted?
      retrieve_potential_matching_users_in_department
    else
      # when user_row is not persisted, we retrieve the potential matching users at the
      # user_list_upload level to not trigger a new query in each user_row creation
      user_list_upload.potential_matching_users_in_department
    end
  end

  def retrieve_potential_matching_users_in_all_app
    User.active.where(email: email).or(User.active.where(phone_number: phone_number)).or(User.active.where(nir: nir))
  end

  def retrieve_potential_matching_users_in_department
    User.active.joins(:organisations).where(
      affiliation_number: affiliation_number,
      organisations: { department_id: department.id }
    ).or(
      User.active.joins(:organisations).where(
        department_internal_id: department_internal_id,
        organisations: { department_id: department.id }
      )
    )
  end
end
