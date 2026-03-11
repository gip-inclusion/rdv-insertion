module UserListUpload::UserRow::MatchingUser
  private

  def set_matching_user
    return if matching_user.present?
    return if user_save_succeeded?
    return if persisted? && !matching_attribute_changed?

    self.matching_user = find_matching_user
  end

  def find_matching_user
    potential_matching_users_in_department.find do |user|
      user_matches_nir?(user.nir) ||
        user_matches_department_internal_id?(user.department_internal_id) ||
        user_matches_email?(user.email, user.first_name) ||
        user_matches_phone_number?(user.phone_number, user.first_name) ||
        user_matches_affiliation_number_and_role?(user.affiliation_number, user.role)
    end
  end

  def user_matches_nir?(matching_user_nir)
    nir.present? && matching_user_nir.present? && NirHelper.equal?(nir, matching_user_nir)
  end

  def user_matches_phone_number?(matching_user_phone_number, matching_user_first_name)
    phone_number.present? && matching_user_phone_number.present? &&
      first_name.present? && matching_user_first_name.present? &&
      matching_user_first_name.split.first.downcase == first_name.split.first.downcase &&
      matching_user_phone_number == phone_number
  end

  def user_matches_department_internal_id?(matching_user_department_internal_id)
    department_internal_id.present? && matching_user_department_internal_id.present? &&
      matching_user_department_internal_id == department_internal_id
  end

  def user_matches_affiliation_number_and_role?(matching_user_affiliation_number, matching_user_role)
    affiliation_number.present? && matching_user_affiliation_number.present? &&
      role.present? && matching_user_role.present? &&
      matching_user_affiliation_number == affiliation_number &&
      matching_user_role == role
  end

  def user_matches_email?(matching_user_email, matching_user_first_name)
    email.present? && matching_user_email.present? &&
      first_name.present? && matching_user_first_name.present? &&
      matching_user_first_name.split.first.downcase == first_name.split.first.downcase &&
      matching_user_email == email
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

  # rubocop:disable Metrics/AbcSize
  def retrieve_potential_matching_users_in_department
    base = User.active.where(department_id: department.id)
    scope = User.none

    scope = scope.or(base.where(nir: nir)) if nir.present?
    scope = scope.or(base.where(email: email)) if email.present?
    scope = scope.or(base.where(phone_number: phone_number)) if phone_number.present?
    scope = scope.or(base.where(affiliation_number: affiliation_number)) if affiliation_number.present?
    scope = scope.or(base.where(department_internal_id: department_internal_id)) if department_internal_id.present?

    scope
  end
  # rubocop:enable Metrics/AbcSize

  def matching_attribute_changed?
    nir_changed? || phone_number_changed? || department_internal_id_changed? || affiliation_number_changed? ||
      email_changed? || role_changed?
  end
end
