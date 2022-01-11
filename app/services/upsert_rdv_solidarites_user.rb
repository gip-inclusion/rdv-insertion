class UpsertRdvSolidaritesUser < BaseService
  def initialize(
    rdv_solidarites_session:,
    rdv_solidarites_user_attributes:,
    rdv_solidarites_organisation_id:,
    rdv_solidarites_user_id:
  )
    @rdv_solidarites_session = rdv_solidarites_session
    @rdv_solidarites_user_attributes = rdv_solidarites_user_attributes
    @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
    @rdv_solidarites_user_id = rdv_solidarites_user_id
  end

  def call
    upsert_rdv_solidarites_user!
    result.rdv_solidarites_user_id = rdv_solidarites_user_id
  end

  private

  def rdv_solidarites_user_id
    @rdv_solidarites_user_id || user_id_from_email_taken_error || create_rdv_solidarites_user.user.id
  end

  def upsert_rdv_solidarites_user!
    @rdv_solidarites_user_id.present? ? assign_to_org_and_udpate! : create_rdv_solidarites_user!
  end

  def create_rdv_solidarites_user!
    return if create_rdv_solidarites_user.success?

    # If the user already exists, we assign the user to the org by creating the user profile
    # and we then update the user
    return assign_to_org_and_udpate! if email_taken_error?

    result.errors += create_rdv_solidarites_user.errors
    fail!
  end

  def assign_to_org_and_udpate!
    create_user_profile! unless user_belongs_to_org?
    update_rdv_solidarites_user!
  end

  def user_id_from_email_taken_error
    create_rdv_solidarites_user.error_details&.dig("email")&.first&.dig("id")
  end

  def email_taken_error?
    create_rdv_solidarites_user.error_details&.dig("email")&.any? { _1["error"] == "taken" }
  end

  def create_user_profile!
    return if create_user_profile.success?

    result.errors += create_user_profile.errors
    fail!
  end

  def user_belongs_to_org?
    retrieve_organisation_user.user.present?
  end

  def retrieve_organisation_user
    @retrieve_organisation_user ||= RdvSolidaritesApi::RetrieveUser.call(
      rdv_solidarites_user_id: rdv_solidarites_user_id,
      rdv_solidarites_organisation_id: @rdv_solidarites_organisation_id,
      rdv_solidarites_session: @rdv_solidarites_session
    )
  end

  def create_user_profile
    @create_user_profile || RdvSolidaritesApi::CreateUserProfile.call(
      user_id: rdv_solidarites_user_id,
      organisation_id: @rdv_solidarites_organisation_id,
      rdv_solidarites_session: @rdv_solidarites_session
    )
  end

  def create_rdv_solidarites_user
    @create_rdv_solidarites_user ||= RdvSolidaritesApi::CreateUser.call(
      user_attributes: @rdv_solidarites_user_attributes.merge(organisation_ids: [@rdv_solidarites_organisation_id]),
      rdv_solidarites_session: @rdv_solidarites_session
    )
  end

  def update_rdv_solidarites_user!
    return if update_rdv_solidarites_user.success?

    result.errors += update_rdv_solidarites_user.errors
    fail!
  end

  def update_rdv_solidarites_user
    @update_rdv_solidarites_user ||= RdvSolidaritesApi::UpdateUser.call(
      user_attributes: @rdv_solidarites_user_attributes,
      rdv_solidarites_session: @rdv_solidarites_session,
      rdv_solidarites_user_id: rdv_solidarites_user_id
    )
  end
end
