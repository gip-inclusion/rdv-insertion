module Counters
  class NumberOfConvocationsNoShow
    include Statisfy::Counter

    count every: :participation_updated,
          if: -> { participation.previous_changes[:status].present? },
          if_async: -> { participation.notified? },
          decrement_if: -> { participation.status != "noshow" }
  end
end
