class RetrieveOrganisationsFromAddress < BaseService
  def initialize(address:, department_number:)
    @address = address
    @department_number = department_number
  end

  def call
    fail!("Impossible de trouver une organisation sans adresse") if @address.blank?

    retrieve_address_geocoding_params!
    retrieve_rdv_solidarites_organisations_matching_sector!
    result.organisations = matching_organisations
  end

  private

  def retrieve_address_geocoding_params!
    @geocoding_params = call_service!(
      RetrieveAddressGeocodingParams,
      address: @address, department_number: @department_number
    ).geocoding_params
  end

  def retrieve_rdv_solidarites_organisations_matching_sector!
    @retrieve_rdv_solidarites_organisations_matching_sector ||= call_service!(
      RdvSolidaritesApi::RetrieveOrganisations,
      geo_attributes: @geocoding_params
    )
  end

  def matching_organisations
    Organisation.where(
      rdv_solidarites_organisation_id: @retrieve_rdv_solidarites_organisations_matching_sector.organisations.map(&:id)
    )
  end
end
