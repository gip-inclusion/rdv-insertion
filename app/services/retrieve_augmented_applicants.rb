# Takes applicants and retrieve their rdv solidarites info to return augmented applicants
# which is the combination of these applicants infos in DB and in RDV-Solidarites
class RetrieveAugmentedApplicants < BaseService
  def initialize(applicants:, rdv_solidarites_session:, page:)
    @applicants = applicants
    @rdv_solidarites_session = rdv_solidarites_session
    @page = page
  end

  def call
    result.augmented_applicants = []
    return if @applicants.empty?

    retrieve_augmented_applicants
  end

  private

  def retrieve_augmented_applicants
    retrieve_rdv_solidarites_users
    return if failed?

    @applicants.each do |applicant|
      rdv_solidarites_user = @rdv_solidarites_users.find do |rdv_user|
        rdv_user.id == applicant.rdv_solidarites_user_id
      end

      next unless rdv_solidarites_user

      result.augmented_applicants << AugmentedApplicant.new(applicant, rdv_solidarites_user)
    end
  end

  def retrieve_rdv_solidarites_users
    if retrieve_rdv_solidarites_users_service.success?
      @rdv_solidarites_users = retrieve_rdv_solidarites_users_service.rdv_solidarites_users
      result.next_page = retrieve_rdv_solidarites_users_service.next_page
    else
      result.errors += retrieve_rdv_solidarites_users_service.errors
    end
  end

  def retrieve_rdv_solidarites_users_service
    @retrieve_rdv_solidarites_users_service ||= RetrieveRdvSolidaritesUsers.call(
      ids: @applicants.pluck(:rdv_solidarites_user_id),
      rdv_solidarites_session: @rdv_solidarites_session,
      organisation_id: @applicants.first.rdv_solidarites_organisation_id,
      page: @page
    )
  end
end
