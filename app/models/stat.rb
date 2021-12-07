class Stat
  include ActiveModel::Model

  attr_accessor :applicants, :invitations, :agents, :organisations, :rdvs

  def percentage_of_applicants_oriented_in_time
    (applicants_oriented_in_less_than_30_days.count / (applicants_orientable_in_time.count.nonzero? || 1).to_f) * 100
  end

  def applicants_oriented_in_less_than_30_days
    applicants.select do |applicant|
      applicant.orientation_delay_in_days < 30 && applicant.oriented?
    end
  end

  def applicants_orientable_in_time
    # Remove from calculation applicants that are not oriented yet and
    # were created less than 30 days ago
    applicants - applicants.where("applicants.created_at > ?", 30.days.ago).where.not(status: %w[resolved rdv_seen])
  end

  def average_orientation_delay_in_days
    cumulated_orientation_delays = 0
    applicants.oriented.each do |applicant|
      cumulated_orientation_delays += applicant.orientation_delay_in_days
    end

    cumulated_orientation_delays / (applicants.oriented.count.nonzero? || 1).to_f
  end

  def average_rdv_delay_in_days
    cumulated_rdv_delays = 0
    Rdv.seen.each do |rdv|
      cumulated_rdv_delays += rdv.delay_in_days
    end

    cumulated_rdv_delays / (rdvs.seen.count.nonzero? || 1).to_f
  end

  def percentage_of_no_show
    (rdvs.noshow.count / (rdvs.closed.count.nonzero? || 1).to_f) * 100
  end

  def sent_invitations
    invitations.where.not(sent_at: nil).uniq(&:applicant_id)
  end
end
