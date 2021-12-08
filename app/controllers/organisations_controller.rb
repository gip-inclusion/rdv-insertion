class OrganisationsController < ApplicationController
  def index
    @organisations = policy_scope(Organisation)
    redirect_to organisation_applicants_path(@organisations.first) if @organisations.size == 1
  end

  def geolocated
    @organisations = policy_scope(Organisation).where(department: department)
    return render_impossible_to_geolocate if retrieve_geolocalisation.failure?

    if retrieve_organisations_attrituted_to_sector.success?
      render json: {
        organisations: @organisations,
        success: true,
        organisations_attributed_to_sector: organisations_attributed_to_sector
      }
    else
      render json: {
        errors: retrieve_organisations_attrituted_to_sector.errors,
        success: false,
        organisations: @organisations
      }
    end
  end

  private

  def department
    @department ||= Department.find_by!(number: params[:department_number])
  end

  def retrieve_geolocalisation
    @retrieve_geolocalisation ||= RetrieveGeolocalisation.call(
      address: params[:address],
      department: department
    )
  end

  def render_impossible_to_geolocate
    render json: {
      success: false,
      organisations: @organisations,
      errors: ["Impossible de géolocaliser le bénéficiaire à partir de l'addresse donnée"]
    }
  end

  def retrieve_organisations_attrituted_to_sector
    @retrieve_organisations_attrituted_to_sector ||= \
      RdvSolidaritesApi::RetrieveOrganisations.call(
        rdv_solidarites_session: rdv_solidarites_session,
        geo_attributes: {
          departement_number: department.number,
          city_code: retrieve_geolocalisation.city_code,
          street_ban_id: retrieve_geolocalisation.street_ban_id
        }
      )
  end

  def retrieved_rdv_solidarites_organisations
    retrieve_organisations_attrituted_to_sector.organisations
  end

  def organisations_attributed_to_sector
    @organisations.select do |org|
      org.rdv_solidarites_organisation_id.in?(retrieved_rdv_solidarites_organisations.map(&:id))
    end
  end
end
