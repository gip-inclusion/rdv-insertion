module UserListUpload::UserRow::MatchingUser
  private

  def set_matching_user
    return if matching_user
    return if user_save_succeeded?
    return if persisted? && !matching_attribute_changed?

    self.matching_user = find_matching_user
  end

  def find_matching_user
    users = potential_matching_users_in_department
    find_by_nir(users) ||
      find_by_department_internal_id(users) ||
      find_by_email(users) ||
      find_by_phone_number(users) ||
      find_by_affiliation_number_and_role(users)
  end

  def find_by_nir(users)
    users.find { |user| matches_nir?(user.nir) }
  end

  def find_by_department_internal_id(users)
    users.find { |user| matches_department_internal_id?(user.department_internal_id) }
  end

  def find_by_email(users)
    users.find { |user| matches_email?(user.email, user.first_name) }
  end

  def find_by_phone_number(users)
    users.find { |user| matches_phone_number?(user.phone_number, user.first_name) }
  end

  def find_by_affiliation_number_and_role(users)
    users.find { |user| matches_affiliation_number_and_role?(user.affiliation_number, user.role) }
  end

  def matches_nir?(candidate_nir)
    nir.present? && candidate_nir.present? && NirHelper.equal?(nir, candidate_nir)
  end

  def matches_department_internal_id?(candidate_department_internal_id)
    department_internal_id.present? && candidate_department_internal_id.present? &&
      candidate_department_internal_id == department_internal_id
  end

  def matches_email?(candidate_email, candidate_first_name)
    email.present? && candidate_email.present? &&
      first_name.present? && candidate_first_name.present? &&
      candidate_first_name.split.first.downcase == first_name.split.first.downcase &&
      candidate_email == email
  end

  def matches_phone_number?(candidate_phone_number, candidate_first_name)
    phone_number.present? && candidate_phone_number.present? &&
      first_name.present? && candidate_first_name.present? &&
      candidate_first_name.split.first.downcase == first_name.split.first.downcase &&
      candidate_phone_number == phone_number
  end

  def matches_affiliation_number_and_role?(candidate_affiliation_number, candidate_role)
    affiliation_number.present? && candidate_affiliation_number.present? &&
      role.present? && candidate_role.present? &&
      candidate_affiliation_number == affiliation_number &&
      candidate_role == role
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
    base = User.active.joins(:organisations).where(organisations: { department_id: department.id })
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
      email_changed? || role_changed? || first_name_changed?
  end
end
