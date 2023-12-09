module Counters
  class NumberOfInvitationsNoShow
    include Statisfy::Counter

    count every: :participation_updated,
          if: -> { participation.previous_changes[:status].present? },
          if_async: -> { !participation.notified? && participation.rdv_context.sent_invitations.any? },
          decrement_if: -> { participation.status != "noshow" },
          decrement_on_destroy: true
  end
end
