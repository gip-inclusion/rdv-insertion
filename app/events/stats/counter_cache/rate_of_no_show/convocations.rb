module Stats
  module CounterCache
    module RateOfNoShow
      class Convocations
        include Counter
        include Common

        def run_if(participation)
          participation.previous_changes[:status].present? && participation.notifications.any?
        end
      end
    end
  end
end
