module Stats
  module CounterCache
    module RateOfNoShow
      class Convocations
        include Counter
        include Common

        catch_events :update_participation_successful, if: lambda { |participation|
          participation.previous_changes[:status].present? && participation.notifications.any?
        }
      end
    end
  end
end
