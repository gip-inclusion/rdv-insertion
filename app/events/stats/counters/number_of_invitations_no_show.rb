module Stats
  module Counters
    class NumberOfInvitationsNoShow
      include Counter

      count every: [:update_participation],
            where: -> { participation.previous_changes[:status].present? },
            where_async: -> { participation.invitation? },
            decrement_if: -> { participation.status != "noshow" }
    end
  end
end
