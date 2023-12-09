module Counters
  class NumberOfConvocationsSeen
    include Statisfy::Counter

    count every: :participation_updated,
          if: -> { participation.previous_changes[:status].present? },
          if_async: -> { participation.notified? },
          decrement_if: -> { participation.status != "seen" },
          decrement_on_destroy: true
  end
end
