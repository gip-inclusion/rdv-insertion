module Counters
    class NumberOfInvitationsNoShow
      include Statisfy::Counter

      count every: :participation_updated,
            if: -> { participation.previous_changes[:status].present? },
            if_async: -> { participation.invitation? },
            decrement_if: -> { participation.status != "noshow" }
  end
end
