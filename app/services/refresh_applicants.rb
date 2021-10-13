# Retrieves the RDV-Solidarites users linked to the applicants and updates them
# if they changed in RDV-Solidarites
class RefreshApplicants < BaseService
  def initialize(applicants:, rdv_solidarites_session:)
    @applicants = applicants
    @rdv_solidarites_session = rdv_solidarites_session
  end

  def call
    return if @applicants.empty?

    retrieve_rdv_solidarites_users!
    refresh_applicants
  end

  private

  def refresh_applicants
    @applicants.each do |applicant|
      rdv_solidarites_user = rdv_solidarites_users.find do |rdv_user|
        rdv_user.id == applicant.rdv_solidarites_user_id
      end

      next unless rdv_solidarites_user

      applicant.assign_attributes(
        rdv_solidarites_user.attributes.slice(*Applicant::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES).compact
      )
      applicant.save! if applicant.changed?
    end
  end

  def retrieve_rdv_solidarites_users!
    return if retrieve_rdv_solidarites_users.success?

    result.errors += retrieve_rdv_solidarites_users.errors
    fail!
  end

  def rdv_solidarites_users
    retrieve_rdv_solidarites_users.users
  end

  def retrieve_rdv_solidarites_users
    @retrieve_rdv_solidarites_users ||= RetrieveRdvSolidaritesResources.call(
      rdv_solidarites_session: @rdv_solidarites_session,
      organisation_id: @applicants.first.rdv_solidarites_organisation_id,
      resource_name: "users",
      additional_args: @applicants.pluck(:rdv_solidarites_user_id)
    )
  end
end
