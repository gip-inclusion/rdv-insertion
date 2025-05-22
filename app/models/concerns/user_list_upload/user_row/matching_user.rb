module UserListUpload::UserRow::MatchingUser
  private

  def set_matching_user
    return if matching_user_id.present?
    return if user_save_succeeded?
    return if persisted? && !matching_attribute_changed?

    matching_user = find_matching_user
    self.matching_user_id = matching_user.id if matching_user
  end

  def find_matching_user
    users_with_department_specific_attributes = potential_matching_users_by_department_specific_attributes.to_a
    users_with_common_attributes = potential_matching_users_by_common_attributes.to_a

    find_user_by_nir(users_with_common_attributes) ||
      find_user_by_department_internal_id(users_with_department_specific_attributes) ||
      find_user_by_email(users_with_common_attributes) ||
      find_user_by_phone_number(users_with_common_attributes) ||
      find_user_by_affiliation_number_and_role(users_with_department_specific_attributes)
  end

  def find_user_by_nir(users)
    return if nir.blank?

    users.find { |user| user_matches_nir?(user.nir) }
  end

  def find_user_by_department_internal_id(users)
    return if department_internal_id.blank?

    users.find { |user| user_matches_department_internal_id?(user) }
  end

  def find_user_by_email(users)
    return if email.blank?

    users.find { |user| user_matches_email?(user) }
  end

  def find_user_by_phone_number(users)
    return if phone_number.blank?

    users.find { |user| user_matches_phone_number?(user) }
  end

  def find_user_by_affiliation_number_and_role(users)
    return if affiliation_number.blank? || role.blank?

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

  def potential_matching_users_by_common_attributes
    if persisted?
      retrieve_potential_matching_users_by_common_attributes
    else
      # when user_row is not persisted, we retrieve the potential matching users at the
      # user_list_upload level to not trigger a new query in each user_row creation
      user_list_upload.potential_matching_users_by_common_attributes
    end
  end

  def potential_matching_users_by_department_specific_attributes
    if persisted?
      retrieve_potential_matching_users_by_department_specific_attributes
    else
      # when user_row is not persisted, we retrieve the potential matching users at the
      # user_list_upload level to not trigger a new query in each user_row creation
      user_list_upload.potential_matching_users_by_department_specific_attributes
    end
  end

  def retrieve_potential_matching_users_by_common_attributes
    scope = User.none

    scope = scope.or(active_users_in_department.where(email: email)) if email.present?
    scope = scope.or(active_users_in_department.where(phone_number: phone_number)) if phone_number.present?
    scope = scope.or(active_users_in_department.where(nir: nir)) if nir.present?

    scope
  end

  def retrieve_potential_matching_users_by_department_specific_attributes
    scope = User.none

    if affiliation_number.present?
      scope = scope.or(active_users_in_department.where(affiliation_number: affiliation_number))
    end
    if department_internal_id.present?
      scope = scope.or(active_users_in_department.where(department_internal_id: department_internal_id))
    end

    scope
  end

  def active_users_in_department
    @active_users_in_department ||= User.active.where(department_id: department.id)
  end

  def matching_attribute_changed?
    nir_changed? || phone_number_changed? || department_internal_id_changed? || affiliation_number_changed? ||
      email_changed? || role_changed?
  end
end
