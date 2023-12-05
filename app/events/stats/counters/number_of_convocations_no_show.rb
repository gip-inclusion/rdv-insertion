module Stats
  module Counters
    class NumberOfConvocationsNoShow
      include Counter

      count every: :update_participation,
            where: -> { participation.previous_changes[:status].present? },
            where_async: -> { participation.convocation? },
            decrement_if: -> { participation.status != "noshow" }
    end
  end
end
