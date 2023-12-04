module Stats
  module Counters
    class NumberOfConvocationsNoShow
      include Counter

      count every: [:update_participation], where: -> { participation.previous_changes[:status].present? }

      def process_event
        return unless participation.notifications.any?

        participation.status == "noshow" ? increment : decrement
      end
    end
  end
end
