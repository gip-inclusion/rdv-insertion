class UserListUpload::Collection
  attr_reader :user_rows, :user_list_upload

  SEARCHABLE_ATTRIBUTES = %i[
    first_name last_name email phone_number affiliation_number
  ].freeze

  def initialize(user_list_upload:)
    @user_list_upload = user_list_upload
    @user_rows = load_user_rows
  end

  def update_rows(rows_data)
    rows_to_update = []
    rows_data.each do |row_data|
      user_row = find(row_data[:id])
      user_row.assign_attributes(row_data.except(:id))
      rows_to_update << user_row
    end
    save!(rows_to_update)
  end

  def save(user_rows)
    user_rows.each(&:format_attributes)
    UserListUpload::UserRow.import(
      user_rows,
      on_duplicate_key_update: UserListUpload::UserRow.updatable_attributes
    )
  end

  def save!(user_rows)
    user_rows.each(&:format_attributes)
    UserListUpload::UserRow.import!(
      user_rows,
      on_duplicate_key_update: UserListUpload::UserRow.updatable_attributes
    )
  end

  def user_rows_with_errors
    user_rows.reject(&:user_valid?)
  end

  def user_rows_enriched_with_cnaf_data
    user_rows.select(&:changed_by_cnaf_data?)
  end

  def user_rows_selected_for_user_save
    user_rows.select(&:selected_for_user_save?)
  end

  def user_rows_with_user_save_attempted
    user_rows_selected_for_user_save.select(&:attempted_user_save?)
  end

  def user_rows_with_user_save_success
    user_rows_with_user_save_attempted.select(&:user_save_succeded?)
  end

  def user_rows_with_user_save_errors
    user_rows_with_user_save_attempted.reject do |user_row|
      user_row.last_user_save_attempt.success?
    end
  end

  def all_saves_attempted?
    user_rows_selected_for_user_save.all?(&:attempted_user_save?)
  end

  def user_rows_selected_for_invitation
    user_rows.select(&:selected_for_invitation?)
  end

  def all_invitations_attempted?
    user_rows_selected_for_invitation.all?(&:invitation_attempted?)
  end

  def user_rows_with_invitation_attempted
    user_rows.select(&:invitation_attempted?)
  end

  def user_rows_with_invitation_errors
    user_rows_with_invitation_attempted.select(&:all_invitations_failed?)
  end

  def sort_by!(sort_by:, sort_direction:)
    user_rows.sort_by! do |user_row|
      # we place nil values at the end
      [user_row.send(sort_by).nil? ? 1 : 0, user_row.send(sort_by)]
    end
    user_rows.reverse! if sort_direction == "desc"
  end

  def search!(query)
    user_rows.select! do |user_row|
      SEARCHABLE_ATTRIBUTES.any? do |attribute|
        user_row.user.send(attribute).to_s.downcase.include?(query.downcase)
      end
    end
  end

  def count
    user_rows.length
  end

  def find(user_row_id)
    user_rows.find { |user_row| user_row.id == user_row_id }
  end

  private

  def load_user_rows
    @user_list_upload.user_rows.preload(
      matching_user: [:organisations, :motif_categories, :referents, :tags, :address_geocoding, {
        archives: :organisation
      }],
      invitation_attempts: :invitation,
      user_save_attempts: [user: [:address_geocoding, { invitations: [:follow_up] }]]
    ).order(created_at: :asc).to_a
  end
end
