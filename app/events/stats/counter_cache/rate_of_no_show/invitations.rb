module Stats
  module CounterCache
    module RateOfNoShow
      class Invitations
        include Counter
        include Common

        catch_events :update_participation_successful, if: lambda { |participation|
          participation.previous_changes[:status].present? &&
            participation.notifications.blank? &&
            participation.rdv_context_invitations.present?
        }
      end
    end
  end
end
