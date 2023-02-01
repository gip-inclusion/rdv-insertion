module Stats
  class ComputeRateOfAutonomousApplicants < BaseService
    def initialize(applicants:, rdvs:, sent_invitations:, for_focused_month: false, date: nil)
      @applicants = applicants
      @rdvs = rdvs
      @sent_invitations = sent_invitations
      @for_focused_month = for_focused_month
      @date = date
    end

    def call
      result.data = compute_rate_of_autonomous_applicants
    end

    private

    # Rate of rdvs taken in autonomy
    def compute_rate_of_autonomous_applicants
      (autonomous_applicants.count / (
        selected_applicants.count.nonzero? || 1
      ).to_f) * 100
    end

    def autonomous_applicants
      @autonomous_applicants ||= selected_applicants.select do |applicant|
        applicant.id.in?(rdvs_created_by_user.flat_map(&:applicant_ids))
      end
    end

    def selected_applicants
      @selected_applicants ||=
        @for_focused_month ? invited_applicants_created_during_focused_month : invited_applicants
    end

    def rdvs_created_by_user
      @rdvs_created_by_user ||= @rdvs.preload(:applicants).select(&:created_by_user?)
    end

    def invited_applicants
      @invited_applicants ||= \
        @applicants.where(id: @sent_invitations.map(&:applicant_id).uniq)
    end

    def invited_applicants_created_during_focused_month
      @invited_applicants_created_during_focused_month ||= \
        invited_applicants.where(created_at: @date.all_month)
    end
  end
end
