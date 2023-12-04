User.find_each do |user|
  Stats::Counters::UsersCreated.initialize_with(user)
end

Agent.find_each do |agent|
  Stats::Counters::NumberOfAgents.initialize_with(agent)
end

Participation.find_each do |participation|
  Stats::Counters::RdvsTaken.initialize_with(participation)
  Stats::Counters::UsersWithRdvTaken.initialize_with(participation)
  Stats::Counters::UsersWithRdvTakenInLessThan30Days.initialize_with(participation)
  Stats::Counters::UsersWithRdvSeen.initialize_with(participation)
  Stats::Counters::DaysBetweenInvitationAndRdv.initialize_with(participation)
  Stats::Counters::RdvsTakenAutonomously.initialize_with(participation)
  Stats::Counters::RdvsTakenByAgent.initialize_with(participation)
  Stats::Counters::RdvsTakenByPrescripteur.initialize_with(participation)
  Stats::Counters::NumberOfConvocationsSeen.initialize_with(participation, skip_validation: true)
  Stats::Counters::NumberOfConvocationsNoShow.initialize_with(participation, skip_validation: true)
  Stats::Counters::NumberOfInvitationsNoShow.initialize_with(participation, skip_validation: true)
  Stats::Counters::NumberOfInvitationsSeen.initialize_with(participation, skip_validation: true)
end

Invitation.where.not(sent_at: nil).find_each do |invitation|
  Stats::Counters::InvitationsSent.initialize_with(invitation, skip_validation: true)
end
