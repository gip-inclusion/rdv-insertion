module Stats
  module Counters
    class DaysBetweenInvitationAndRdv
      include Statisfy::Counter

      count every: :participation_created,
            type: :average,
            value: -> { participation.rdv_context.time_between_invitation_and_rdv_in_days },
            if: lambda {
              participation.rdv_context.participations.size < 2 &&
                participation.rdv_context.invitations.present?
            }
    end
  end
end
