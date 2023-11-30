User.find_each do |user|
  Stats::CounterCache::UsersCreated.initialize_with(user)
end

Agent.find_each do |agent|
  Stats::CounterCache::NumberOfAgents.initialize_with(agent)
end

Participation.find_each do |participation|
  Stats::CounterCache::RdvsTaken.initialize_with(participation)
  Stats::CounterCache::UsersWithRdvTaken.initialize_with(participation)
  Stats::CounterCache::UsersWithRdvTakenInLessThan30Days.initialize_with(participation)
  Stats::CounterCache::UsersWithRdvSeen.initialize_with(participation)
  Stats::CounterCache::DaysBetweenInvitationAndRdv.initialize_with(participation)
  Stats::CounterCache::RdvsTakenAutonomously.initialize_with(participation)
  Stats::CounterCache::RdvsTakenByAgent.initialize_with(participation)
  Stats::CounterCache::RdvsTakenByPrescripteur.initialize_with(participation)
  Stats::CounterCache::NumberOfConvocationsSeen.initialize_with(participation, skip_validation: true)
  Stats::CounterCache::NumberOfConvocationsNoShow.initialize_with(participation, skip_validation: true)
  Stats::CounterCache::NumberOfInvitationsNoShow.initialize_with(participation, skip_validation: true)
  Stats::CounterCache::NumberOfInvitationsSeen.initialize_with(participation, skip_validation: true)
end

Invitation.where.not(sent_at: nil).find_each do |invitation|
  Stats::CounterCache::InvitationsSent.initialize_with(invitation, skip_validation: true)
end
