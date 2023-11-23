module Stats
  module CounterCache
    module RateOfNoShow
      class Invitations
        include Counter
        include Common

        catch_events :update_participation_successful, if: lambda { |participation|
          participation.previous_changes[:status].present?
        }

        def process_event
          return unless participation.notifications.blank? && participation.rdv_context_invitations.present?

          update_noshow_and_seen_counters
        end
      end
    end
  end
end
