module Stats
  module CounterCache
    class RateOfNoShowInvitations
      include Counter

      def self.value(scope:, month: nil)
        number_of_seen = NumberOfInvitationsSeen.value(scope:, month:)
        number_of_noshow = NumberOfInvitationsNoShow.value(scope:, month:)

        (number_of_noshow / ((number_of_seen + number_of_noshow).nonzero? || 1).to_f) * 100
      end
    end
  end
end
