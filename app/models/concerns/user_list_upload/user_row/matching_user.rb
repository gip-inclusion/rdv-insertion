module UserListUpload::UserRow::MatchingUser
  def matching_user_to_retrieve?
    matching_attribute_changed? && matching_user.nil? && !user_save_succeeded?
  end

  def find_matching_user(users)
    find_user_by_nir(users) ||
      find_user_by_department_internal_id(users) ||
      find_user_by_email(users) ||
      find_user_by_phone_number(users)
  end

  def matchable_nir = NirHelper.format_nir(nir)
  def matchable_email = cnaf_data["email"] || email
  def matchable_phone_number = PhoneNumberHelper.format_phone_number(cnaf_data["phone_number"] || phone_number)

  private

  def set_matching_user
    self.matching_user = find_matching_user(potential_matching_users) if matching_user_to_retrieve?
  end

  def potential_matching_users
    if persisted?
      user_list_upload.potential_matching_users_for([self])
    else
      # when user_row is not persisted, we retrieve the potential matching users at the
      # user_list_upload level to not trigger a new query in each user_row creation
      user_list_upload.potential_matching_users
    end
  end

  def find_user_by_nir(users)
    users.find { |user| matches_nir?(user.nir) }
  end

  def find_user_by_department_internal_id(users)
    users.find { |user| matches_department_internal_id?(user.department_internal_id) }
  end

  def find_user_by_email(users)
    users.find { |user| matches_email?(user.email, user.first_name) }
  end

  def find_user_by_phone_number(users)
    users.find { |user| matches_phone_number?(user.phone_number, user.first_name) }
  end

  def matches_nir?(candidate_nir)
    nir.present? && candidate_nir.present? && NirHelper.equal?(nir, candidate_nir)
  end

  def matches_department_internal_id?(candidate_department_internal_id)
    department_internal_id.present? && candidate_department_internal_id.present? &&
      candidate_department_internal_id == department_internal_id
  end

  def matches_email?(candidate_email, candidate_first_name)
    matchable_email.present? && candidate_email.present? &&
      first_name.present? && candidate_first_name.present? &&
      candidate_first_name.split.first.downcase == first_name.split.first.downcase &&
      candidate_email == matchable_email
  end

  def matches_phone_number?(candidate_phone_number, candidate_first_name)
    matchable_phone_number.present? && candidate_phone_number.present? &&
      first_name.present? && candidate_first_name.present? &&
      candidate_first_name.split.first.downcase == first_name.split.first.downcase &&
      candidate_phone_number == matchable_phone_number
  end

  def matching_attribute_changed?
    nir_changed? || phone_number_changed? || department_internal_id_changed? ||
      email_changed? || first_name_changed? || cnaf_data_changed?
  end
end
