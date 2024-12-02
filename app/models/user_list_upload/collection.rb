class UserListUpload::Collection
  attr_reader :user_rows

  delegate :each, to: :user_rows

  SEARCHABLE_ATTRIBUTES = %i[
    first_name last_name email phone_number affiliation_number
  ].freeze

  def initialize(user_list_upload:, matching_users:, referents_from_list:, tags_from_list:, organisations:)
    @user_list_upload = user_list_upload
    @user_list = user_list_upload.user_list.map(&:deep_symbolize_keys)
    @matching_users = matching_users
    @referents_from_list = referents_from_list
    @tags_from_list = tags_from_list
    @organisations = organisations
    @user_rows = build_user_rows
  end

  def update_rows(rows_data_by_uid)
    rows_data_by_uid.each do |user_list_uid, data|
      assign_row_data(user_list_uid, data)
    end

    save
  end

  def update_row(user_list_uid, data)
    assign_row_data(user_list_uid, data)
    save
  end

  def save
    @user_list_upload.update(user_list: user_rows.map(&:row_data))
  end

  def user_rows_with_errors
    user_rows.reject(&:valid?)
  end

  def user_rows_enriched_with_cnaf_data
    user_rows.select(&:changed_by_cnaf_data?)
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
        user_row.user_attributes[attribute].to_s.downcase.include?(query.downcase)
      end
    end
  end

  def save_user(uid)
    find(uid).save_user
  end

  def count
    @user_list.count
  end

  private

  def build_user_rows
    @user_list.map do |row_data|
      UserListUpload::Row.new(
        row_data: row_data.deep_symbolize_keys,
        matching_user: matching_user_for(row_data),
        referent_to_assign: referent_to_assign_for(row_data),
        tags_to_assign: tags_to_assign_for(row_data),
        organisation_to_assign: organisation_to_assign_for(row_data)
      )
    end
  end

  def assign_row_data(user_list_uid, data)
    user_row = find(user_list_uid)
    user_row&.assign_data(data)
  end

  def find(user_list_uid)
    user_rows.find { |user_row| user_row.uid == user_list_uid }
  end

  def matching_user_for(row_data)
    return unless row_data[:matching_user_id]

    @matching_users.find { |user| user.id == row_data[:matching_user_id] }
  end

  def referent_to_assign_for(row_data)
    return unless row_data[:referent_email]

    @referents_from_list.find { |referent| referent.email == row_data[:referent_email] }
  end

  def tags_to_assign_for(row_data)
    return unless row_data[:tags]

    @tags_from_list.select { |tag| row_data[:tags].include?(tag.name) }
  end

  def organisation_to_assign_for(row_data)
    return @organisations.first if @organisations.length == 1
    return unless row_data[:organisation_search_term]

    @organisations.find do |organisation|
      row_data[:organisation_search_term].downcase.in?(
        [organisation.name, organisation.slug].map(&:downcase)
      )
    end
  end
end
