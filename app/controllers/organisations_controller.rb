class OrganisationsController < ApplicationController
  def index
    @organisations = policy_scope(Organisation).includes(:department, :category_configurations)
    @organisations_by_department = @organisations.sort_by(&:department_number).group_by(&:department)
    return unless @organisations.to_a.length == 1

    redirect_to default_list_organisation_users_path(@organisations.first)
  end

  def geolocated
    @department_organisations = policy_scope(Organisation).preload(category_configurations: :motif_category)
                                                          .where(department: department)
    return render_impossible_to_geolocate if retrieve_address_geocoding_params.geocoding_params.nil?

    if retrieve_relevant_organisations.success?
      render json: {
        success: true,
        department_organisations: @department_organisations,
        geolocated_organisations: organisations_relevant_to_sector
      }
    else
      render json: {
        success: false,
        errors: retrieve_relevant_organisations.errors,
        department_organisations: @department_organisations
      }
    end
  end

  private

  def department
    @department ||= Department.find_by!(number: params[:department_number])
  end

  def retrieve_address_geocoding_params
    @retrieve_address_geocoding_params ||= RetrieveAddressGeocodingParams.call(
      address: params[:address],
      department_number: department.number
    )
  end

  def render_impossible_to_geolocate
    render json: {
      success: false,
      department_organisations: @department_organisations,
      errors: ["Impossible de géolocaliser le bénéficiaire à partir de l'adresse donnée"]
    }
  end

  def retrieve_relevant_organisations
    @retrieve_relevant_organisations ||=
      RdvSolidaritesApi::RetrieveOrganisations.call(
        geo_attributes: {
          departement_number: department.number,
          city_code: retrieve_address_geocoding_params.geocoding_params[:city_code],
          street_ban_id: retrieve_address_geocoding_params.geocoding_params[:street_ban_id]
        }
      )
  end

  def retrieved_rdv_solidarites_organisations
    retrieve_relevant_organisations.organisations
  end

  def organisations_relevant_to_sector
    @department_organisations.select do |org|
      org.rdv_solidarites_organisation_id.in?(retrieved_rdv_solidarites_organisations.map(&:id))
    end
  end
end
