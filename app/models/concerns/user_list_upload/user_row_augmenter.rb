module UserListUpload::UserRowAugmenter
  def augment
    matching_user = find_matching_user
    self.matching_user_id = matching_user.id if matching_user
  end

  private

  def find_matching_user
    find_matching_user_in_all_app || find_matching_user_in_department
  end

  def find_matching_user_in_all_app
    user_list_upload.potential_matching_users_in_all_app.find do |matching_user|
      user_matches_nir?(matching_user.nir) ||
        user_matches_phone_number?(matching_user) ||
        user_matches_email?(matching_user)
    end
  end

  def find_matching_user_in_department
    user_list_upload.potential_matching_users_in_department.find do |matching_user|
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
end
