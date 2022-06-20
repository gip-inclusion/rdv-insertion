# rubocop:disable Metrics/AbcSize

class CreateStats < ActiveRecord::Migration[7.0]
  def change # rubocop:disable Metrics/MethodLength
    create_table :stats do |t|
      t.integer :applicants_count
      t.json :applicants_count_grouped_by_month
      t.integer :rdvs_count
      t.json :rdvs_count_grouped_by_month
      t.integer :sent_invitations_count
      t.json :sent_invitations_count_grouped_by_month
      t.float :percentage_of_no_show
      t.json :percentage_of_no_show_grouped_by_month
      t.float :average_time_between_invitation_and_rdv_in_days
      t.json :average_time_between_invitation_and_rdv_in_days_by_month
      t.float :average_time_between_rdv_creation_and_start_in_days
      t.json :average_time_between_rdv_creation_and_start_in_days_by_month
      t.float :rate_of_applicants_with_rdv_seen_in_less_than_30_days
      t.json :rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month
      t.integer :agents_count
      t.string :department_number

      t.timestamps
    end

    add_index "stats", ["department_number"], unique: true
    up_only do
      CreateStatsJob.perform_async
    end
  end
end

# rubocop:enable Metrics/AbcSize
