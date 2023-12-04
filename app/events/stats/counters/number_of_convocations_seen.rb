module Stats
  module Counters
    class NumberOfConvocationsSeen
      include Counter

      count every: :update_participation,
            where: -> { participation.previous_changes[:status].present? },
            where_async: -> { participation.convocation? },
            decrement_if: -> { participation.status != "seen" }
    end
  end
end
