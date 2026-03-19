class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Covers set_follow_ups and status/action_required filters which query by both columns
    add_index :follow_ups, [:user_id, :motif_category_id]

    # Covers preload(:organisations) and order_by_created_at; existing index has organisation_id
    # as leading column so cannot serve user_id-first lookups
    add_index :users_organisations, :user_id

    # Covers invitation date filters (user_id + ORDER BY created_at) to avoid a separate sort pass
    add_index :invitations, [:user_id, :created_at]

    # Covers convocation date filters (participation_id + event + created_at range)
    add_index :notifications, [:participation_id, :event, :created_at]
  end
end
