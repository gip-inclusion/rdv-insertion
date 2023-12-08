module Counters
  class DaysBetweenInvitationAndRdv
    include Statisfy::Aggregate

    aggregate every: :participation_created,
              value: -> { participation.rdv_context.time_between_invitation_and_rdv_in_days },
              if: lambda {
                participation.rdv_context.participations.size < 2 &&
                  participation.rdv_context.invitations.present?
              }
  end
end
