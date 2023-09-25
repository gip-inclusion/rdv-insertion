Stat.find_each do |stat|
  stat.rate_of_applicants_oriented =
    Stats::ComputeRateOfApplicantsWithRdvSeen.call(rdv_contexts: stat.orientation_rdv_contexts_sample).value

  date = stat.statable&.created_at || DateTime.parse("01/01/2022")
  stat.rate_of_applicants_oriented_grouped_by_month = {}

  while date < Time.zone.now
    oriented_rate = stat.rate_of_applicants_oriented_grouped_by_month
    oriented_rate_for_date =
      Stats::ComputeRateOfApplicantsWithRdvSeen.call(
        rdv_contexts: stat.orientation_rdv_contexts_sample.where(created_at: date.all_month)
      ).value.round

    # We don't want to start the hash until we have a value
    if oriented_rate != {} || oriented_rate_for_date != 0
      oriented_rate.merge!({ date.strftime("%m/%Y") => oriented_rate_for_date })
      stat.rate_of_applicants_oriented_grouped_by_month = oriented_rate
    end

    date += 1.month
  end

  stat.save!
end
