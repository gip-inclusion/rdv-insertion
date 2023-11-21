module Stats
  module CounterCache
    module RateOfNoShow
      class Invitations
        include Counter
        include Common

        def run_if(participation)
          participation.previous_changes[:status].present? &&
            participation.notifications.blank? &&
            participation.rdv_context_invitations.present?
        end
      end
    end
  end
end
