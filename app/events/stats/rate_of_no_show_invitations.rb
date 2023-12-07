module Stats
  class RateOfNoShowInvitations
    include Statisfy::Counter

    def self.value(scope:, month: nil)
      number_of_seen = Counters::NumberOfInvitationsSeen.value(scope:, month:)
      number_of_noshow = Counters::NumberOfInvitationsNoShow.value(scope:, month:)

      (number_of_noshow / ((number_of_seen + number_of_noshow).nonzero? || 1).to_f) * 100
    end
  end
end
