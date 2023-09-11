Stats::GlobalStats::UpsertStatsJob.perform_async

Stat.find_each do |stat|
  date = stat.statable.present? ? stat.statable.created_at : Time.zone.parse("15/01/2022 12:00")
  while date < 1.month.ago
    rate_for_invitations = stat[:rate_of_no_show_for_invitations_grouped_by_month] || {}
    rate_for_invitations_for_date =
      Stats::ComputeRateOfNoShow.call(
        participations: stat.participations_without_notifications_sample.where(created_at: date.all_month)
      ).value.round
    rate_for_invitations.merge!({ date.strftime("%m/%Y") => rate_for_invitations_for_date })
    stat[:rate_of_no_show_for_invitations_grouped_by_month] = rate_for_invitations

    rate_for_convocations = stat[:rate_of_no_show_for_convocations_grouped_by_month] || {}
    rate_for_convocations_for_date =
      Stats::ComputeRateOfNoShow.call(
        participations: stat.participations_with_notifications_sample.where(created_at: date.all_month)
      ).value.round
    rate_for_convocations.merge!({ date.strftime("%m/%Y") => rate_for_convocations_for_date })
    stat[:rate_of_no_show_for_convocations_grouped_by_month] = rate_for_convocations

    date += 1.month
  end
  stat.save!
end
