class MigrateOptionalRdvSubscriptionToInvitations < ActiveRecord::Migration[7.1]
  def change
    Invitation
      .joins(follow_up: :motif_category)
      .where(follow_up: { motif_categories: { optional_rdv_subscription: true } })
      .find_each do |invitation|
      invitation.update!(expires_at: nil)
    end

    drop_column :motif_categories, :optional_rdv_subscription
  end
end
