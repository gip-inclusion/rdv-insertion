module Users::Sortable
  extend ActiveSupport::Concern

  include SortParams

  private

  def sortable_attributes
    %w[first_name last_name]
  end

  def order_users
    if sort_params_valid?
      custom_order
    else
      default_order
    end
  end

  def custom_order
    @users = @users.order("#{sort_by} #{sort_direction}")
  end

  def default_order
    if archived_scope?
      archived_order
    elsif @current_motif_category
      order_by_follow_ups
    else
      order_by_created_at
    end
  end

  def archived_order
    @users = @users.order("archives.created_at desc")
  end

  def order_by_follow_ups
    @users = @users.select("users.*, follow_ups.created_at")
                   .order("follow_ups.created_at desc")
  end

  def order_by_created_at
    @users = @users.select("users.*, MIN(users_organisations.created_at) AS min_created_at")
                   .group("users.id")
                   .order(min_created_at: :desc)
  end
end
