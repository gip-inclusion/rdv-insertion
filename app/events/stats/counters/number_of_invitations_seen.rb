module Stats
  module Counters
    class NumberOfInvitationsSeen
      include Counter

      count every: :update_participation,
            if: -> { participation.previous_changes[:status].present? },
            if_async: -> { participation.invitation? },
            decrement_if: -> { participation.status != "seen" }
    end
  end
end
