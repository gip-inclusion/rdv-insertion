module UserListUpload::Augmenter
  extend ActiveSupport::Concern

  private

  def augment_user_list!
    self.user_list = user_list.map do |user_attributes|
      matching_user = find_matching_user(user_attributes)
      user_attributes.merge(matching_user ? { matching_user_id: matching_user.id } : {})
    end
  end

  def potential_matching_users
    @potential_matching_users ||= User.where(
      id: potential_matching_users_in_all_app.ids + potential_matching_users_in_department.ids
    ).distinct
  end

  def potential_matching_users_in_all_app
    User.where(email: user_list.pluck("email").compact)
        .or(User.where(phone_number: user_list.pluck("phone_number").compact))
        .or(User.where(nir: user_list.pluck("nir").compact)).select(:id)
  end

  def potential_matching_users_in_department
    User.joins(:organisations).where(
      affiliation_number: user_list.pluck("affiliation_number").compact,
      organisations: { department_id: department.id }
    ).or(
      User.joins(:organisations).where(
        department_internal_id: user_list.pluck("department_internal_id").compact,
        organisations: { department_id: department.id }
      )
    ).select(:id)
  end

  def find_matching_user(user_attributes)
    potential_matching_users.find do |matching_user|
      user_matches_nir?(user_attributes["nir"], matching_user.nir) ||
        user_matches_phone_number?(user_attributes, matching_user) ||
        user_matches_department_internal_id?(
          user_attributes["department_internal_id"], matching_user.department_internal_id
        ) ||
        user_matches_affiliation_number?(user_attributes, matching_user) ||
        user_matches_email?(user_attributes, matching_user)
    end
  end

  def user_matches_nir?(user_nir, matching_user_nir)
    user_nir.present? && matching_user_nir.present? && NirHelper.equal?(user_nir, matching_user_nir)
  end

  def user_matches_phone_number?(user_attributes, matching_user)
    user_attributes["phone_number"].present? && matching_user.phone_number.present? &&
      user_attributes["first_name"].present? && matching_user.first_name.present? &&
      matching_user.first_name.split.first.downcase == user_attributes["first_name"].split.first.downcase &&
      matching_user.phone_number == user_attributes["phone_number"]
  end

  def user_matches_department_internal_id?(user_department_internal_id, matching_user_department_internal_id)
    user_department_internal_id.present? && matching_user_department_internal_id.present? &&
      matching_user_department_internal_id == user_department_internal_id
  end

  def user_matches_affiliation_number?(user_attributes, matching_user)
    user_attributes["affiliation_number"].present? && matching_user.affiliation_number.present? &&
      user_attributes["role"].present? && matching_user.role.present? &&
      matching_user.affiliation_number == user_attributes["affiliation_number"] &&
      matching_user.role == user_attributes["role"]
  end

  def user_matches_email?(user_attributes, matching_user)
    user_attributes["email"].present? && matching_user.email.present? &&
      matching_user.first_name.present? && user_attributes["first_name"].present? &&
      matching_user.first_name.split.first.downcase == user_attributes["first_name"].split.first.downcase &&
      matching_user.email == user_attributes["email"]
  end
end
