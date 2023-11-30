module Stats
  module CounterCache
    class RateOfNoShowConvocations
      include Counter

      def self.value(scope:, month: nil)
        number_of_seen = NumberOfConvocationsSeen.value(scope:, month:)
        number_of_noshow = NumberOfConvocationsNoShow.value(scope:, month:)

        (number_of_noshow / ((number_of_seen + number_of_noshow).nonzero? || 1).to_f) * 100
      end
    end
  end
end
