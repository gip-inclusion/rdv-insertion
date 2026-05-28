class UserListUpload::CreateCreneauxSnapshot < BaseService
  attr_reader :user_list_upload

  def initialize(user_list_upload:)
    @user_list_upload = user_list_upload
  end

  def call
    save_record!(
      UserListUpload::CreneauxSnapshot.new(
        user_list_upload:, number_of_creneaux_available:
      )
    )
  end

  private

  def number_of_creneaux_available
    user_list_upload.agent.with_rdv_solidarites_session do
      call_service!(
        RdvSolidaritesApi::RetrieveCreneauAvailability,
        link_params: {
          motif_category_short_name: user_list_upload.motif_category_short_name,
          organisation_ids: user_list_upload.organisations.map(&:rdv_solidarites_organisation_id)
        },
        total_count: true
      ).creneau_availability_count
    end
  end
end
