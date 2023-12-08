User.find_each do |user|
  Counters::UsersCreated.initialize_with(user)
end

Agent.find_each do |agent|
  Counters::NumberOfAgents.initialize_with(agent)
end

Participation.find_each do |participation|
  Counters::RdvsTaken.initialize_with(participation)
  Counters::UsersWithRdvTaken.initialize_with(participation)
  Counters::UsersWithRdvTakenInLessThan30Days.initialize_with(participation)
  Counters::UsersWithRdvSeen.initialize_with(participation)
  Counters::DaysBetweenInvitationAndRdv.initialize_with(participation)
  Counters::RdvsTakenAutonomously.initialize_with(participation)
  Counters::RdvsTakenByAgent.initialize_with(participation)
  Counters::RdvsTakenByPrescripteur.initialize_with(participation)
  Counters::NumberOfConvocationsSeen.initialize_with(participation, skip_validation: true)
  Counters::NumberOfConvocationsNoShow.initialize_with(participation, skip_validation: true)
  Counters::NumberOfInvitationsNoShow.initialize_with(participation, skip_validation: true)
  Counters::NumberOfInvitationsSeen.initialize_with(participation, skip_validation: true)
end

Invitation.where.not(sent_at: nil).find_each do |invitation|
  Counters::InvitationsSent.initialize_with(invitation, skip_validation: true)
end
