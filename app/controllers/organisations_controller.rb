class OrganisationsController < ApplicationController
  PERMITTED_PARAMS = [
    :name, :phone_number, :email, :slug, :rdv_solidarites_organisation_id,
    :department_id, :safir_code, :logo, :remove_logo
  ].freeze

  before_action :set_organisation_for_configuration, :set_department,
                only: [:show_infos, :edit_infos, :update_infos,
                       :show_data_retention, :edit_data_retention, :update_data_retention]

  def index
    @organisations = policy_scope(Organisation).includes(:department, :category_configurations)
    @organisations_by_department = @organisations.sort_by(&:department_number).group_by(&:department)
    return unless @organisations.to_a.length == 1

    redirect_to default_list_organisation_users_path(@organisations.first)
  end

  def show_infos; end

  def edit_infos; end

  def update_infos
    @organisation.assign_attributes(organisation_params)
    @success = update_organisation.success?
    if @success
      flash.now[:success] = "Informations mises à jour"
    else
      flash.now[:error] = update_organisation.errors&.join(", ")
    end
    respond_to :turbo_stream
  end

  def show_data_retention; end

  def edit_data_retention; end

  def update_data_retention
    @organisation.assign_attributes(data_retention_params)
    @success = @organisation.save
    if @success
      flash.now[:success] = "Durée de conservation mise à jour"
    else
      flash.now[:error] = @organisation.errors.full_messages.to_sentence
    end
    respond_to :turbo_stream
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

  def search
    @department_organisations = policy_scope(Organisation).where(department: department)
    @matching_organisations = @department_organisations.search_by_text(params[:search_terms])
    render json: {
      success: true,
      matching_organisations: @matching_organisations,
      department_organisations: @department_organisations
    }
  end

  private

  def organisation_params
    params.expect(organisation: PERMITTED_PARAMS)
  end

  def set_organisation
    @organisation = policy_scope(Organisation).find(params[:id])
    authorize @organisation
  end

  def set_organisation_for_configuration
    @organisation = policy_scope(Organisation).find(params[:id])
    authorize @organisation, :configure?
  end

  def set_department
    @department = @organisation.department
  end

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

  def update_organisation
    @update_organisation ||= Organisations::Update.call(organisation: @organisation)
  end

  def data_retention_params
    params.expect(organisation: [:data_retention_duration_in_months])
  end
end
