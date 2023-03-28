class FileConfigurationsController < ApplicationController
  PERMITTED_PARAMS = [
    :sheet_name, :title_column, :first_name_column, :last_name_column, :role_column, :email_column, :nir_column,
    :phone_number_column, :birth_date_column, :birth_name_column, :street_number_column, :street_type_column,
    :address_column, :postal_code_column, :city_column, :department_internal_id_column, :affiliation_number_column,
    :rights_opening_date_column, :organisation_search_terms_column, :referent_email_column, :pole_emploi_id_column
  ].freeze

  before_action :set_organisation, only: [:show, :new, :create, :edit, :confirm_update, :update]
  before_action :set_file_configuration, only: [:show, :edit, :confirm_update, :update]
  before_action :set_edit_form_url, :set_edit_form_html_method, only: [:edit, :update]

  def show; end

  def new
    @file_configuration = FileConfiguration.new
  end

  def edit; end

  def confirm_update
    @file_configuration.assign_attributes(**formatted_params)
    render turbo_stream: turbo_stream.replace(
      "remote_modal", partial: "confirm_update", locals: {
        organisation: @organisation,
        current_file_configuration: @file_configuration,
        new_file_configuration: FileConfiguration.new(**formatted_params.compact_blank)
      }
    )
  end

  def create
    @file_configuration = FileConfiguration.new(**formatted_params)
    if @file_configuration.save
      flash.now[:success] = "Le fichier d'import a été créé avec succès"
    else
      render_errors
    end
  end

  def update
    @file_configuration.assign_attributes(**formatted_params)
    if @file_configuration.save
      flash.now[:success] = "Le fichier d'import a été modifié avec succès"
    else
      render_errors
    end
  end

  private

  def file_configuration_params
    params.require(:file_configuration).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def formatted_params
    # we nullify blank column names for validations to be accurate
    file_configuration_params.to_h do |k, v|
      [k, k.to_s.in?(FileConfiguration.column_attributes_names) ? v.presence : v]
    end
  end

  def render_errors
    render turbo_stream: turbo_stream.replace(
      "remote_modal", partial: "file_configuration_form", locals: {
        organisation: @organisation,
        file_configuration: @file_configuration,
        errors: @file_configuration.errors.full_messages,
        url: form_url,
        method: form_method,
        title: form_title
      }
    )
  end

  def form_title
    @edit_form_url ? "Modifier fichier d'import" : "Créer fichier d'import"
  end

  def form_url
    @edit_form_url.presence || organisation_file_configurations_path(@organisation)
  end

  def form_method
    @edit_form_html_method.presence || :post
  end

  def set_edit_form_url
    @edit_form_url = \
      if @file_configuration.configurations.length > 1
        organisation_file_configuration_confirm_update_path(@organisation, @file_configuration)
      else
        organisation_file_configuration_path(@organisation, @file_configuration)
      end
  end

  def set_edit_form_html_method
    @edit_form_html_method = \
      if @file_configuration.configurations.length > 1
        :get
      else
        :patch
      end
  end

  def set_organisation
    @organisation = policy_scope(Organisation).find(params[:organisation_id])
    authorize @organisation, :configure?
  end

  def set_file_configuration
    file_configuration_id = params[:file_configuration_id].presence || params[:id]
    @file_configuration = FileConfiguration.find(file_configuration_id)
  end
end
