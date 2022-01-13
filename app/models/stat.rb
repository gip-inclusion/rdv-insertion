class Stat
  include ActiveModel::Model

  attr_accessor :applicants, :invitations, :agents, :organisations, :rdvs

  def relevant_organisations
    organisations.joins(:configuration)
                 .where(configuration: { notify_applicant: false })
  end

  def relevant_applicants
    applicants.joins(:organisations)
              .where(organisations: relevant_organisations)
              .where.not(status: %w[resolved deleted])
  end

  def relevant_rdvs
    rdvs.joins(:applicants).where(applicants: relevant_applicants)
  end

  def percentage_of_applicants_oriented_in_time
    (applicants_oriented_in_less_than_30_days.count / (applicants_orientable_in_time.count.nonzero? || 1).to_f) * 100
  end

  def applicants_oriented_in_less_than_30_days
    relevant_applicants.select do |applicant|
      applicant.rdv_seen? && applicant.orientation_delay_in_days && applicant.orientation_delay_in_days < 30
    end
  end

  def applicants_orientable_in_time
    # Remove from calculation applicants that are not oriented yet and
    # were created less than 30 days ago
    non_pertinent_applicants = relevant_applicants.where("applicants.created_at > ?", 30.days.ago)
                                                  .where.not(status: "rdv_seen")
    relevant_applicants - non_pertinent_applicants
  end

  def average_orientation_delay_in_days
    cumulated_orientation_delays = 0
    relevant_applicants.rdv_seen.each do |applicant|
      next unless applicant.orientation_delay_in_days

      cumulated_orientation_delays += applicant.orientation_delay_in_days
    end

    cumulated_orientation_delays / (relevant_applicants.rdv_seen.count.nonzero? || 1).to_f
  end

  def average_rdv_delay_in_days
    cumulated_rdv_delays = 0
    relevant_rdvs.seen.each do |rdv|
      cumulated_rdv_delays += rdv.delay_in_days
    end

    cumulated_rdv_delays / (relevant_rdvs.seen.count.nonzero? || 1).to_f
  end

  def percentage_of_no_show
    (relevant_rdvs.noshow.count / (relevant_rdvs.resolved.count.nonzero? || 1).to_f) * 100
  end

  def sent_invitations
    invitations.where.not(sent_at: nil).uniq(&:applicant_id)
  end
end
