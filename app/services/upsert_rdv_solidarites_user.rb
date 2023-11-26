class UpsertRdvSolidaritesUser < BaseService
  def initialize(user:, organisation:, rdv_solidarites_session:)
    @user = user
    @organisation = organisation
    @rdv_solidarites_session = rdv_solidarites_session
  end

  def call
    upsert_rdv_solidarites_user
    result.rdv_solidarites_user_id = rdv_solidarites_user_id
  end

  private

  def rdv_solidarites_user_id
    @user.rdv_solidarites_user_id || user_id_from_email_taken_error || create_rdv_solidarites_user.user.id
  end

  def upsert_rdv_solidarites_user
    @user.rdv_solidarites_user_id.present? ? sync_orgs_and_update : create_or_update_rdv_solidarites_user
  end

  def create_or_update_rdv_solidarites_user
    return if create_rdv_solidarites_user.success?

    # If the user already exists in RDV-S, we assign the user to the org by updating him.
    if email_taken_error?
      return sync_orgs_and_update unless existing_user

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

  def sync_orgs_and_update
    sync_organisations
    update_rdv_solidarites_user
  end

  def user_id_from_email_taken_error
    create_rdv_solidarites_user.error_details&.dig("email")&.first&.dig("id")
  end

  def email_taken_error?
    create_rdv_solidarites_user.error_details&.dig("email")&.any? { _1["error"] == "taken" }
  end

  def sync_organisations
    @sync_organisations ||= call_service!(
      RdvSolidaritesApi::CreateUserProfiles,
      user_id: rdv_solidarites_user_id,
      organisation_ids: @user.organisations.map(&:rdv_solidarites_organisation_id),
      rdv_solidarites_session: @rdv_solidarites_session
    )
  end

  def create_rdv_solidarites_user
    @create_rdv_solidarites_user ||= RdvSolidaritesApi::CreateUser.call(
      user_attributes:
        rdv_solidarites_user_attributes.merge(
          organisation_ids: @user.organisations.map(&:rdv_solidarites_organisation_id)
        ),
      rdv_solidarites_session: @rdv_solidarites_session
    )
  end

  def update_rdv_solidarites_user
    @update_rdv_solidarites_user ||= call_service!(
      RdvSolidaritesApi::UpdateUser,
      user_attributes: rdv_solidarites_user_attributes,
      rdv_solidarites_session: @rdv_solidarites_session,
      rdv_solidarites_user_id: rdv_solidarites_user_id
    )
  end

  def rdv_solidarites_user_attributes
    user_attributes = @user.attributes
                           .symbolize_keys
                           .slice(*User::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
                           .transform_values(&:presence)
                           .compact
    user_attributes.delete(:email) if @user.conjoint?
    user_attributes
  end
end
