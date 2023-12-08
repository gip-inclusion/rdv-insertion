module Counters
  class NumberOfInvitationsSeen
    include Statisfy::Counter

    count every: :participation_updated,
          if: -> { participation.previous_changes[:status].present? },
          if_async: -> { !participation.notified? && participation.rdv_context.sent_invitations.any? },
          decrement_if: -> { participation.status != "seen" }
  end
end
