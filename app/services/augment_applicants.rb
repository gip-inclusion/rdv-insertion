class AugmentApplicants < BaseService
  def initialize(applicants:, rdv_solidarites_session:)
    @applicants = applicants
    @rdv_solidarites_session = rdv_solidarites_session
  end

  def call
    @result = { errors: [], augmented_applicants: [] }
    return @result if @applicants.empty?

    augment_applicants!
    @result
  end

  private

  def augment_applicants!
    fetch_rdv_solidarites_users!
    return if failed?

    @result[:augmented_applicants] = @applicants.map do |applicant|
      rdv_solidarites_user = @rdv_solidarites_users.find do |rdv_user|
        rdv_user.id == applicant.rdv_solidarites_user_id
      end

      next unless rdv_solidarites_user

      AugmentedApplicant.new(applicant, rdv_solidarites_user)
    end.compact
  end

  def fetch_rdv_solidarites_users!
    if fetch_rdv_solidarites_users.success?
      @rdv_solidarites_users = fetch_rdv_solidarites_users.rdv_solidarites_users
    else
      @result[:errors] = fetch_rdv_solidarites_users.errors
    end
  end

  def failed?
    @result[:errors].present?
  end

  def fetch_rdv_solidarites_users
    @fetch_rdv_solidarites_users ||= FetchRdvSolidaritesUsers.call(
      ids: @applicants.pluck(:rdv_solidarites_user_id),
      rdv_solidarites_session: @rdv_solidarites_session,
      organisation_id: @applicants.first.rdv_solidarites_organisation_id
    )
  end
end
