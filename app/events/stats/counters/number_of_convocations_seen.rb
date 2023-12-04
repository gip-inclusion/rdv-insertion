module Stats
  module Counters
    class NumberOfConvocationsSeen
      include Counter

      count every: [:update_participation], where: -> { participation.previous_changes[:status].present? }

      def process_event
        return unless participation.notifications.any?

        participation.status == "seen" ? increment : decrement
      end
    end
  end
end
