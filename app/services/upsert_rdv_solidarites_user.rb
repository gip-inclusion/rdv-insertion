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
    upsert_rdv_solidarites_user
    result.rdv_solidarites_user_id = rdv_solidarites_user_id
  end

  private

  def rdv_solidarites_user_id
    @rdv_solidarites_user_id || user_id_from_email_taken_error || create_rdv_solidarites_user.user.id
  end

  def upsert_rdv_solidarites_user
    @rdv_solidarites_user_id.present? ? assign_to_org_and_update : create_or_update_rdv_solidarites_user
  end

  def create_or_update_rdv_solidarites_user
    return if create_rdv_solidarites_user.success?

    # If the user already exists in RDV-S, we check if he is in RDVI. If not we assign the user to the org
    # by creating the user profile and we then update the user.
    if email_taken_error?
      return assign_to_org_and_update unless existing_user

      fail!(
        "Un usager avec cette adresse mail existe déjà sur RDVI avec d'autres attributs: " \
        "id #{existing_user.id}"
      )
    end

    result.errors += create_rdv_solidarites_user.errors
    fail!
  end

  def existing_user
    @existing_user ||= User.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
  end

  def assign_to_org_and_update
    create_user_profile unless user_belongs_to_org?
    update_rdv_solidarites_user
  end

  def user_id_from_email_taken_error
    create_rdv_solidarites_user.error_details&.dig("email")&.first&.dig("id")
  end

  def email_taken_error?
    create_rdv_solidarites_user.error_details&.dig("email")&.any? { _1["error"] == "taken" }
  end

  def create_user_profile
    @create_user_profile ||= call_service!(
      RdvSolidaritesApi::CreateUserProfile,
      user_id: rdv_solidarites_user_id,
      organisation_id: @rdv_solidarites_organisation_id,
      rdv_solidarites_session: @rdv_solidarites_session
    )
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

  def create_rdv_solidarites_user
    @create_rdv_solidarites_user ||= RdvSolidaritesApi::CreateUser.call(
      user_attributes: @rdv_solidarites_user_attributes.merge(organisation_ids: [@rdv_solidarites_organisation_id]),
      rdv_solidarites_session: @rdv_solidarites_session
    )
  end

  def update_rdv_solidarites_user
    @update_rdv_solidarites_user ||= call_service!(
      RdvSolidaritesApi::UpdateUser,
      user_attributes: @rdv_solidarites_user_attributes,
      rdv_solidarites_session: @rdv_solidarites_session,
      rdv_solidarites_user_id: rdv_solidarites_user_id
    )
  end
end
