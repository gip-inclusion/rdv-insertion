class AddDisplayInStatsToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :display_in_stats, :boolean, default: true

    ENV.fetch("ORGANISATION_IDS_WHERE_STATS_DISABLED", "").split(",").each do |id|
      Organisation.find_by(id:)&.update!(display_in_stats: false)
    end
  end
end
