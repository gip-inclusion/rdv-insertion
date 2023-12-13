User.includes(:departments, :organisations).find_each(batch_size: 30_000) do |user|
  Counters::UsersCreated.trigger_with(user)
end

Agent.includes(:departments, :organisations).find_each(batch_size: 30_000) do |agent|
  Counters::NumberOfAgents.trigger_with(agent)
end

Participation
  .includes(:user, :department, :organisation, :notifications, :rdv_context_invitations, rdv_context: :participations)
  .find_each do |participation|
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

Invitation.includes(:department, :organisations).where.not(sent_at: nil).find_each do |invitation|
  Counters::InvitationsSent.trigger_with(invitation, skip_validation: true)
end
