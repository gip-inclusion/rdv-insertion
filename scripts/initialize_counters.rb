User.find_each do |user|
  Counters::UsersCreated.trigger_with(user)
end

Agent.find_each do |agent|
  Counters::NumberOfAgents.trigger_with(agent)
end

Participation.find_each do |participation|
  Counters::RdvsTaken.trigger_with(participation)
  Counters::UsersWithRdvTaken.trigger_with(participation)
  Counters::UsersWithRdvTakenInLessThan30Days.trigger_with(participation)
  Counters::UsersWithRdvSeen.trigger_with(participation)
  Counters::DaysBetweenInvitationAndRdv.trigger_with(participation)
  Counters::RdvsTakenAutonomously.trigger_with(participation)
  Counters::RdvsTakenByAgent.trigger_with(participation)
  Counters::RdvsTakenByPrescripteur.trigger_with(participation)
  Counters::NumberOfConvocationsSeen.trigger_with(participation, skip_validation: true)
  Counters::NumberOfConvocationsNoShow.trigger_with(participation, skip_validation: true)
  Counters::NumberOfInvitationsNoShow.trigger_with(participation, skip_validation: true)
  Counters::NumberOfInvitationsSeen.trigger_with(participation, skip_validation: true)
end

Invitation.where.not(sent_at: nil).find_each do |invitation|
  Counters::InvitationsSent.trigger_with(invitation, skip_validation: true)
end
