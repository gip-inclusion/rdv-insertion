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
    find_user_by_nir ||
      find_user_by_department_internal_id ||
      find_user_by_email ||
      find_user_by_phone_number ||
      find_user_by_affiliation_number_and_role
  end

  def find_user_by_nir
    return if nir.blank?

    potential_matching_users.find { |user| user_matches_nir?(user.nir) }
  end

  def find_user_by_department_internal_id
    return if department_internal_id.blank?

    potential_matching_users.find { |user| user_matches_department_internal_id?(user) }
  end

  def find_user_by_email
    return if email.blank?

    potential_matching_users.find { |user| user_matches_email?(user) }
  end

  def find_user_by_phone_number
    return if phone_number.blank?

    potential_matching_users.find { |user| user_matches_phone_number?(user) }
  end

  def find_user_by_affiliation_number_and_role
    return if affiliation_number.blank? || role.blank?

    potential_matching_users.find { |user| user_matches_affiliation_number_and_role?(user) }
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

  def potential_matching_users
    @potential_matching_users ||= if persisted?
                                    retrieve_potential_matching_users.to_a
                                  else
                                    # when user_row is not persisted, we retrieve the potential matching users at the
                                    # user_list_upload level to not trigger a new query in each user_row creation
                                    user_list_upload.potential_matching_users.to_a
                                  end
  end

  # rubocop:disable Metrics/AbcSize
  def retrieve_potential_matching_users
    scope = User.none

    scope = scope.or(active_users_in_department.where(email:)) if email.present?
    scope = scope.or(active_users_in_department.where(phone_number:)) if phone_number.present?
    scope = scope.or(active_users_in_department.where(affiliation_number:)) if affiliation_number.present?
    scope = scope.or(active_users_in_department.where(department_internal_id:)) if department_internal_id.present?
    scope = scope.or(active_users_in_department.where(nir:)) if nir.present?

    scope
  end
  # rubocop:enable Metrics/AbcSize

  def active_users_in_department
    @active_users_in_department ||= User.active.where(department_id: department.id)
  end

  def matching_attribute_changed?
    nir_changed? || phone_number_changed? || department_internal_id_changed? || affiliation_number_changed? ||
      email_changed? || role_changed?
  end
end
