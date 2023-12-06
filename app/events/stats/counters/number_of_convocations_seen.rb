module Stats
  module Counters
    class NumberOfConvocationsSeen
      include Counter

      count every: :update_participation,
            if: -> { participation.previous_changes[:status].present? },
            if_async: -> { participation.notified? },
            decrement_if: -> { participation.status != "seen" }
    end
  end
end
