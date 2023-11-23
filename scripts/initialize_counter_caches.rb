User.find_each do |user|
  Stats::CounterCache::UsersCreated.initialize_with(user)
end

Agent.find_each do |agent|
  Stats::CounterCache::NumberOfAgents.initialize_with(agent)
end

Participation.find_each do |participation|
  Stats::CounterCache::RdvsTaken.initialize_with(participation)
  Stats::CounterCache::RateOfUsersWithRdvSeenInLessThanThirtyDays.initialize_with(participation)
  Stats::CounterCache::RateOfUsersWithRdvSeen.initialize_with(participation)
  Stats::CounterCache::DaysBetweenInvitationAndRdv.initialize_with(participation)
  Stats::CounterCache::RateOfAutonomousUsers.initialize_with(participation)
  Stats::CounterCache::RateOfNoShow::Convocations.initialize_with(participation, skip_validation: true)
  Stats::CounterCache::RateOfNoShow::Invitations.initialize_with(participation, skip_validation: true)
end

Invitation.where.not(sent_at: nil).find_each do |invitation|
  Stats::CounterCache::InvitationsSent.initialize_with(invitation, skip_validation: true)
end
