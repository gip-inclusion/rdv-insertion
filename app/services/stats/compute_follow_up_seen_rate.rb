module Stats
  class ComputeFollowUpSeenRate < BaseService
    def initialize(follow_ups:, target_delay_days:, consider_orientation_rdv: false)
      @follow_ups = follow_ups
      @target_delay_days = target_delay_days
      @consider_orientation_rdv = consider_orientation_rdv
    end

    def call
      result.value = compute_percentage_seen_within_delay
    end

    private

    attr_reader :follow_ups, :target_delay_days, :consider_orientation_rdv

    def compute_percentage_seen_within_delay
      return 0.0 if mature_follow_ups.empty?

      (follow_ups_seen_within_delay.count / mature_follow_ups.count.to_f) * 100
    end

    def follow_ups_seen_within_delay
      @follow_ups_seen_within_delay ||= begin
        matches = []
        mature_seen_follow_ups.find_in_batches(batch_size: 1000) do |batch|
          matches += batch.select do |follow_up|
            meets_delay_criteria?(follow_up)
          end
        end
        matches
      end
    end

    def meets_delay_criteria?(follow_up)
      return false unless follow_up.days_between_follow_up_creation_and_first_seen_rdv

      if consider_orientation_rdv
        within_target_delay?(follow_up) || within_orientation_rdv_delay?(follow_up)
      else
        within_target_delay?(follow_up)
      end
    end

    def within_target_delay?(follow_up)
      follow_up.days_between_follow_up_creation_and_first_seen_rdv < target_delay_days
    end

    def within_orientation_rdv_delay?(follow_up)
      follow_up.days_between_first_orientation_seen_rdv_and_first_seen_rdv&.< target_delay_days
    end

    def mature_seen_follow_ups
      @mature_seen_follow_ups ||= FollowUp
                                  .where(id: mature_follow_ups)
                                  .joins(:participations)
                                  .where(participations: { status: "seen" })
                                  .distinct
    end

    def mature_follow_ups
      # Ignore recent follow-ups as we can't determine if they'll meet the delay criteria yet
      @mature_follow_ups ||= follow_ups
                             .where("follow_ups.created_at < ?", target_delay_days.days.ago)
                             .to_a
    end
  end
end