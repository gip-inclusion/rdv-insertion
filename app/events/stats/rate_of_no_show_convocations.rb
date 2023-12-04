module Stats
  module Counters
    class RateOfNoShowConvocations
      include Counters::Counter

      def self.value(scope:, month: nil)
        number_of_seen = Counters::NumberOfConvocationsSeen.value(scope:, month:)
        number_of_noshow = Counters::NumberOfConvocationsNoShow.value(scope:, month:)

        (number_of_noshow / ((number_of_seen + number_of_noshow).nonzero? || 1).to_f) * 100
      end
    end
  end
end
