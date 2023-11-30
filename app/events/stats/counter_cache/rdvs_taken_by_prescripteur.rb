module Stats
  module CounterCache
    class RdvsTakenByPrescripteur
      include EventSubscriber
      include Counter

      catch_events :create_participation_successful, if: ->(subject) { subject.created_by == "prescripteur" }

      def identifier
        participation.user_id
      end
    end
  end
end
