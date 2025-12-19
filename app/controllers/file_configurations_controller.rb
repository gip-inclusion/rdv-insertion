class FileConfigurationsController < ApplicationController
  PERMITTED_PARAMS = [
    :sheet_name, :title_column, :first_name_column, :last_name_column, :role_column, :email_column, :nir_column,
    :phone_number_column, :birth_date_column, :birth_name_column, :address_first_field_column,
    :address_second_field_column, :address_third_field_column, :address_fourth_field_column,
    :address_fifth_field_column, :department_internal_id_column, :affiliation_number_column, :tags_column,
    :rights_opening_date_column, :organisation_search_terms_column, :referent_email_column, :france_travail_id_column
  ].freeze

  before_action :set_file_configuration, only: [:show, :edit, :update, :download_template]
  before_action :set_return_to_path, only: [:show, :new, :edit]

  def show; end

  def new
    @file_configuration = FileConfiguration.new
  end

  def edit; end

  def download_template
    # This line ensures the CSV is read as UTF-8
    bom = "\uFEFF"
    csv_data = bom + @file_configuration.column_attributes.values.to_csv
    send_data csv_data,
              filename: "modele-#{current_organisation.name.parameterize}.csv",
              type: "text/csv; charset=utf-8",
              disposition: "attachment"
  end

  def create
    @file_configuration = FileConfiguration.new(file_configuration_params.merge(created_by_agent: current_agent))
    if @file_configuration.save
      turbo_stream_display_success_modal("Le fichier d'import a été créé avec succès")
    else
      turbo_stream_replace_error_list_with(@file_configuration.errors.full_messages)
    end
  end

  def update
    if @file_configuration.update(file_configuration_params)
      turbo_stream_display_success_modal("Le fichier d'import a été modifié avec succès")
    else
      turbo_stream_replace_error_list_with(@file_configuration.errors.full_messages)
    end
  end

  private

  def file_configuration_params
    params.expect(file_configuration: PERMITTED_PARAMS)
  end

  def set_file_configuration
    @file_configuration = FileConfiguration.find(params[:id] || params[:file_configuration_id])
    authorize @file_configuration
  end

  def set_return_to_path
    @return_to_path = url_from(params[:return_to_path])
  end
end
