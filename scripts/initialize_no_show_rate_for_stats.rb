Stat.find_each do |stat|
  stat.rate_of_no_show_for_invitations =
    Stats::ComputeRateOfNoShow.call(participations: stat.participations_after_invitations_sample).value
  stat.rate_of_no_show_for_convocations =
    Stats::ComputeRateOfNoShow.call(participations: stat.participations_with_notifications_sample).value

  date = stat.statable&.created_at || Time.zone.parse("01/01/2022 12:00")
  stat.rate_of_no_show_for_invitations_grouped_by_month = {}
  stat.rate_of_no_show_for_convocations_grouped_by_month = {}

  while date < Time.zone.parse("31/08/2023 12:00")
    rate_for_invitations = stat.rate_of_no_show_for_invitations_grouped_by_month
    rate_for_invitations_for_date =
      Stats::ComputeRateOfNoShow.call(
        participations: stat.participations_after_invitations_sample.where(created_at: date.all_month)
      ).value.round

    if rate_for_invitations != {} || rate_for_invitations_for_date != 0
      rate_for_invitations.merge!({ date.strftime("%m/%Y") => rate_for_invitations_for_date })
      stat.rate_of_no_show_for_invitations_grouped_by_month = rate_for_invitations
    end

    rate_for_convocations = stat.rate_of_no_show_for_convocations_grouped_by_month
    rate_for_convocations_for_date =
      Stats::ComputeRateOfNoShow.call(
        participations: stat.participations_with_notifications_sample.where(created_at: date.all_month)
      ).value.round

    if rate_for_convocations != {} || rate_for_convocations_for_date != 0
      rate_for_convocations.merge!({ date.strftime("%m/%Y") => rate_for_convocations_for_date })
      stat.rate_of_no_show_for_convocations_grouped_by_month = rate_for_convocations
    end

    date += 1.month
  end

  stat.save!
end
