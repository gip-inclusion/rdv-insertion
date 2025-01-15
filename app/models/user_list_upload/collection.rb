# rubocop:disable Metrics/ClassLength
class UserListUpload::Collection
  attr_reader :user_rows, :user_list_upload

  delegate :each, to: :user_rows
  delegate :motif_category, :matching_users, :referents_from_list, :tags_from_list, :organisations,
           to: :user_list_upload

  SEARCHABLE_ATTRIBUTES = %i[
    first_name last_name email phone_number affiliation_number
  ].freeze

  def initialize(user_list_upload:)
    @user_list_upload = user_list_upload
    @user_rows = build_user_rows
  end

  def update_rows(rows_data)
    NewUserListUpload::UserRow.import(
      rows_data, on_duplicate_key_update: NewUserListUpload::UserRow.updatable_attributes
    )
  end

  def update_row(user_list_uid, data)
    find(user_list_uid).update(data)
  end

  def save_row_user(row_uid)
    find(row_uid).save_user
  end

  def save
    NewUserListUpload::UserRow.import(
      user_rows,
      on_duplicate_key_update: { conflict_target: [:id], columns: NewUserListUpload::UserRow.updatable_attributes }
    )
  end

  def save!
    NewUserListUpload::UserRow.import!(
      user_rows,
      on_duplicate_key_update: { conflict_target: [:id], columns: NewUserListUpload::UserRow.updatable_attributes }
    )
  end

  def user_rows_with_errors
    user_rows.reject(&:user_valid?)
  end

  def user_rows_enriched_with_cnaf_data
    user_rows.select(&:changed_by_cnaf_data?)
  end

  def user_rows_marked_for_user_save
    user_rows.select(&:marked_for_user_save?)
  end

  def user_rows_with_user_save_attempted
    user_rows_marked_for_user_save.select(&:attempted_user_save?)
  end

  def user_rows_with_user_save_success
    user_rows_with_user_save_attempted.select(&:user_save_succeded?)
  end

  def user_rows_with_user_save_errors
    user_rows_with_user_save_attempted.reject do |user_row|
      user_row.last_user_save_attempt.success?
    end
  end

  def user_rows_marked_for_invitation
    user_rows.select(&:marked_for_invitation?)
  end

  def user_rows_with_invitation_attempted
    user_rows.select(&:invitation_attempted?)
  end

  def user_rows_with_invitation_errors
    user_rows_with_invitation_attempted.select(&:all_invitations_failed?)
  end

  def all_saves_attempted?
    user_rows_marked_for_user_save.all?(&:attempted_user_save?)
  end

  def mark_selected_rows_for_invitation!(selected_uids)
    user_rows.each do |user_row|
      user_row.mark_for_invitation! if selected_uids.include?(user_row.uid)
    end

    save!
  end

  def mark_selected_rows_for_user_save!(selected_uids)
    user_rows.each do |user_row|
      user_row.mark_for_user_save! if selected_uids.include?(user_row.uid)
    end

    save!
  end

  def invite_row_user(user_list_uid, format)
    user_row = find(user_list_uid)
    return unless user_row.invitable_by?(format)

    user_row.invite(format)
  end

  def sort_by!(sort_by:, sort_direction:)
    @user_rows.sort_by! do |user_row|
      # we place nil values at the end
      [user_row.send(sort_by).nil? ? 1 : 0, user_row.send(sort_by)]
    end
    @user_rows.reverse! if sort_direction == "desc"
  end

  def search!(query)
    @user_rows.select! do |user_row|
      SEARCHABLE_ATTRIBUTES.any? do |attribute|
        user_row.send(attribute).to_s.downcase.include?(query.downcase)
      end
    end
  end

  def count
    @user_rows.length
  end

  def find(user_list_uid)
    user_rows.find { |user_row| user_row.uid == user_list_uid }
  end

  private

  def build_user_rows
    @user_list_upload.user_rows.preload(
      invitation_attempts: :invitation,
      user_save_attempts: [user: [:address_geocoding, { invitations: [:follow_up] }]]
    ).order(created_at: :asc).map do |user_row|
      user_row.assign_attributes(
        referent_to_assign: referent_to_assign_for(user_row),
        tags_to_assign: tags_to_assign_for(user_row),
        organisation_to_assign: organisation_to_assign_for(user_row),
        matching_user: matching_user_for(user_row)
      )
      user_row
    end
  end

  def assign_row_attributes(user_list_uid, data)
    user_row = find(user_list_uid)
    user_row&.assign_attributes(data)
  end

  def matching_user_for(user_row)
    return unless user_row.matching_user_id

    matching_users.find { |user| user.id == user_row.matching_user_id }
  end

  def referent_to_assign_for(user_row)
    return unless user_row.referent_email

    referents_from_list.find { |referent| referent.email == user_row.referent_email }
  end

  def tags_to_assign_for(user_row)
    return unless user_row.tags

    tags_from_list.select { |tag| user_row.tags.include?(tag.value) }
  end

  def organisation_to_assign_for(user_row)
    return organisations.first if organisations.length == 1

    if user_row.assigned_organisation_id
      retrieve_organisation_by_id(user_row.assigned_organisation_id)
    elsif user_row.organisation_search_terms
      retrieve_organisation_by_search_terms(user_row.organisation_search_terms)
    end
  end

  def retrieve_organisation_by_id(organisation_id)
    organisations.find { |organisation| organisation.id == organisation_id }
  end

  def retrieve_organisation_by_search_terms(search_terms)
    organisations.find do |organisation|
      [organisation.name, organisation.slug].compact.map(&:downcase).any? do |attribute|
        search_terms.downcase.in?(attribute)
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
