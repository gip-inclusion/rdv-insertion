# rubocop:disable Metrics/ClassLength

class OrganisationsController < ApplicationController
  PERMITTED_PARAMS = [
    :name, :phone_number, :email, :slug, :independent_from_cd, :logo_filename, :rdv_solidarites_organisation_id,
    :department_id
  ].freeze

  before_action :set_organisation, :set_department, :authorize_organisation_configuration, only: [:show, :edit, :update]
  before_action :set_all_departments, only: :new

  def index
    @organisations = policy_scope(Organisation).includes(:department, :configurations)
    @organisations_by_department = @organisations.sort_by(&:department_number).group_by(&:department)
    redirect_to organisation_applicants_path(@organisations.first) if @organisations.to_a.length == 1
  end

  def show; end

  def new
    @organisation = Organisation.new
    authorize @organisation
  end

  def edit; end

  def create
    @department = Department.find_by(id: params[:department_id])
    @organisation = Organisation.new(department: @department)
    @organisation.assign_attributes(**organisation_params)
    authorize @organisation
    if create_organisation.success?
      redirect_to organisation_applicants_path(@organisation)
    else
      render turbo_stream: turbo_stream.replace(
        "remote_modal", partial: "organisation_form", locals: {
          organisation: @organisation, department: @department,
          errors: create_organisation.errors
        }
      )
    end
  end

  def update
    @organisation.assign_attributes(**organisation_params)
    authorize @organisation
    if update_organisation.success?
      render :show
    else
      flash.now[:error] = update_organisation.errors&.join(",")
      render :edit, status: :unprocessable_entity
    end
  end

  def geolocated
    @department_organisations = policy_scope(Organisation).where(department: department)
    return render_impossible_to_geolocate if retrieve_geolocalisation.failure?

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
    params.require(:organisation).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def set_organisation
    @organisation = policy_scope(Organisation).find(params[:id])
  end

  def set_department
    @department = @organisation.department
  end

  def set_all_departments
    @all_departments = Department.all.order(:number)
  end

  def department
    @department ||= Department.find_by!(number: params[:department_number])
  end

  def retrieve_geolocalisation
    @retrieve_geolocalisation ||= RetrieveGeolocalisation.call(
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
        rdv_solidarites_session: rdv_solidarites_session,
        geo_attributes: {
          departement_number: department.number,
          city_code: retrieve_geolocalisation.city_code,
          street_ban_id: retrieve_geolocalisation.street_ban_id
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
    @update_organisation ||= Organisations::Update.call(
      organisation: @organisation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def create_organisation
    @create_organisation ||= Organisations::Create.call(
      organisation: @organisation,
      current_agent: current_agent,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def authorize_organisation_configuration
    authorize @organisation, :configure?
  end
end

# rubocop:enable Metrics/ClassLength
