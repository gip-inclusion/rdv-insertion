module Stats
  module CounterCache
    module RateOfNoShow
      module Common
        extend ActiveSupport::Concern

        included do
          include EventSubscriber
        end

        class_methods do
          def value(scope:, month: nil)
            number_of_seen = counter_for(group: "seen", scope:, month:)
            number_of_noshow = counter_for(group: "noshow", scope:, month:)

            (number_of_noshow / ((number_of_seen + number_of_noshow).nonzero? || 1).to_f) * 100
          end
        end

        def process_event
          if participation&.status == "noshow"
            increment(group: "noshow")
            decrement(group: "seen")
          elsif participation&.resolved?
            increment(group: "seen")
            decrement(group: "noshow")
          end
        end
      end
    end
  end
end
