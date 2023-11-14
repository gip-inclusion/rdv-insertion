module Stats
  module CounterCache
    class RateOfNoShowForInvitations < Base
      COUNTER = "rate_of_no_show_for_invitations".freeze

      def scopes
        [@subject.department, @subject.organisation]
      end

      def perform
        return if @subject.previous_changes[:status].blank?
        return if @subject.notifications.present? || @subject.rdv_context_invitations.empty?

        if @subject.status == "noshow"
          increment(key: "noshow")
          decrement(key: "seen")
        elsif @subject.resolved?
          increment(key: "seen")
          decrement(key: "noshow")
        end
      end
    end
  end
end
