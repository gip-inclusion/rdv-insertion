class ChangeJsonDefaultValuesInStats < ActiveRecord::Migration[8.0]
  def change
    change_column_default :stats, :users_count_grouped_by_month, from: nil, to: {}
    change_column_default :stats, :rdvs_count_grouped_by_month, from: nil, to: {}
    change_column_default :stats, :sent_invitations_count_grouped_by_month, from: nil, to: {}
    change_column_default :stats, :average_time_between_invitation_and_rdv_in_days_by_month, from: nil, to: {}
    change_column_default :stats, :users_with_rdv_count_grouped_by_month, from: nil, to: {}
    change_column_default :stats, :rate_of_no_show_for_invitations_grouped_by_month, from: nil, to: {}
    change_column_default :stats, :rate_of_no_show_for_convocations_grouped_by_month, from: nil, to: {}
    change_column_default :stats, :rate_of_no_show_grouped_by_month, from: nil, to: {}
    change_column_default :stats, :rate_of_users_oriented_in_less_than_45_days_by_month, from: nil, to: {}
    change_column_default :stats, :rate_of_users_accompanied_in_less_than_30_days_by_month, from: nil, to: {}
    change_column_default :stats, :rate_of_users_oriented_grouped_by_month, from: nil, to: {}
    change_column_default :stats, :rate_of_autonomous_users_grouped_by_month, from: nil, to: {}
  end
end
