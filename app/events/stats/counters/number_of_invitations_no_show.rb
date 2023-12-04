module Stats
  module Counters
    class NumberOfInvitationsNoShow
      include Counter

      count every: [:update_participation], where: -> { participation.previous_changes[:status].present? }

      def process_event
        return unless participation.notifications.blank? && participation.rdv_context_invitations.present?

        participation.status == "noshow" ? increment : decrement
      end
    end
  end
end
