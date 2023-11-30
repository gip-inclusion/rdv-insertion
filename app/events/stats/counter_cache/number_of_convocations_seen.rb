module Stats
  module CounterCache
    class NumberOfConvocationsSeen
      include Counter
      include EventSubscriber

      catch_events :update_participation_successful, if: lambda { |participation|
        participation.previous_changes[:status].present?
      }

      def process_event
        return unless participation.notifications.any?

        participation.status == "seen" ? increment : decrement
      end
    end
  end
end
