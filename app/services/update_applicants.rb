# Retrieves the RDV-Solidarites users linked to the applicants and updates them
# if they changed in RDV-Solidarites
class UpdateApplicants < BaseService
  def initialize(applicants:, rdv_solidarites_session:, page:)
    @applicants = applicants
    @rdv_solidarites_session = rdv_solidarites_session
    @page = page
  end

  def call
    return if @applicants.empty?

    update_applicants
  end

  private

  def update_applicants
    retrieve_rdv_solidarites_users
    return if failed?

    @applicants.each do |applicant|
      rdv_solidarites_user = @rdv_solidarites_users.find do |rdv_user|
        rdv_user.id == applicant.rdv_solidarites_user_id
      end

      next unless rdv_solidarites_user

      applicant.assign_attributes(
        rdv_solidarites_user.attributes.slice(*Applicant::RDV_SOLIDARITES_USER_SHARED_ATTRIBUTES)
      )
      applicant.save if applicant.changed?
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
