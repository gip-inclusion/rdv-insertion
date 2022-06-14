class Stat
  include ActiveModel::Model

  validates :applicants_count, :applicants_count_grouped_by_month, :rdvs_count, :rdvs_count_grouped_by_month,
            :sent_invitations_count, :sent_invitations_count_grouped_by_month, :percentage_of_no_show,
            :percentage_of_no_show_grouped_by_month, :average_time_between_invitation_and_rdv_in_days,
            :average_time_between_invitation_and_rdv_in_days_grouped_by_month,
            :average_time_between_rdv_creation_and_start_in_days,
            :average_time_between_rdv_creation_and_start_in_days_grouped_by_month,
            :percentage_of_applicants_with_rdv_seen_in_less_than_30_days,
            :percentage_of_applicants_with_rdv_seen_in_less_than_30_days_grouped_by_month,
            :agents_count, presence: true
end
