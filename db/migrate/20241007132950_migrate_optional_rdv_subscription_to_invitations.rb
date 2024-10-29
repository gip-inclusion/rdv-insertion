class MigrateOptionalRdvSubscriptionToInvitations < ActiveRecord::Migration[7.1]
  def up
    MotifCategory.where(optional_rdv_subscription: true).find_each do |motif_category|
      motif_category.category_configurations.find_each do |category_configuration|
        category_configuration.update!(number_of_days_before_invitations_expire: nil)
      end
    end

    Invitation
      .joins(follow_up: :motif_category)
      .where(follow_up: { motif_categories: { optional_rdv_subscription: true } })
      .find_each do |invitation|
      invitation.update!(expires_at: nil)
    end

    remove_column :motif_categories, :optional_rdv_subscription
  end

  def down
    add_column :motif_categories, :optional_rdv_subscription, :boolean, default: false, null: false

    Invitation
      .joins(follow_up: :motif_category)
      .where(follow_up: { motif_categories: { optional_rdv_subscription: false } })
      .where(expires_at: nil).find_each do |invitation|
      invitation.follow_up.motif_category.update!(optional_rdv_subscription: true)
    end
  end
end
