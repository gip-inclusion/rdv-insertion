module Stats
  module CounterCache
    class NumberOfConvocationsNoShow
      include Counter

      catch_events :update_participation_successful, if: lambda { |participation|
        participation.previous_changes[:status].present?
      }

      def process_event
        return unless participation.notifications.any?

        participation.status == "noshow" ? increment : decrement
      end
    end
  end
end
