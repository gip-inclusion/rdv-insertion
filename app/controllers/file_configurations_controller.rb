class FileConfigurationsController < ApplicationController
  PERMITTED_PARAMS = [
    :sheet_name, :title_column, :first_name_column, :last_name_column, :role_column, :email_column,
    :phone_number_column, :birth_date_column, :birth_name_column, :street_number_column, :street_type_column,
    :address_column, :postal_code_column, :city_column, :department_internal_id_column, :affiliation_number_column,
    :rights_opening_date_column, :organisation_search_terms_column, :referent_email_column
  ].freeze

  before_action :set_organisation, only: [:show, :new, :create, :edit, :update, :update_for_all_configurations]
  before_action :set_file_configuration, only: [:show, :edit, :update]

  def show; end

  def new
    @file_configuration = FileConfiguration.new
    render partial: "new"
  end

  def edit
    render partial: "edit"
  end

  def create
    @file_configuration = FileConfiguration.new(**formatted_params)
    if @file_configuration.save
      flash.now[:success] = "Le fichier d'import a été créé avec succès"
    else
      render turbo_stream: turbo_stream.replace(
        "remote_modal", partial: "new", locals: {
          organisation: @organisation, file_configuration: @file_configuration,
          errors: @file_configuration.errors.full_messages
        }
      )
    end
  end

  def update
    @file_configuration.assign_attributes(**formatted_params)
    if @file_configuration.valid? && @file_configuration.configurations.length > 1
      confirm_file_configuration_update
    elsif @file_configuration.save
      flash.now[:success] = "Le fichier d'import a été modifié avec succès"
    else
      render turbo_stream: turbo_stream.replace(
        "remote_modal", partial: "edit", locals: {
          organisation: @organisation, file_configuration: @file_configuration,
          errors: @file_configuration.errors.full_messages
        }
      )
    end
  end

  def update_for_all_configurations
    @file_configuration = FileConfiguration.find(params[:file_configuration_id])
    @file_configuration.assign_attributes(**formatted_params)
    if @file_configuration.save
      flash.now[:success] = "Le fichier d'import a été modifié avec succès"
    else
      render turbo_stream: turbo_stream.replace(
        "remote_modal", partial: "common/error_modal", locals: {
          errors: @file_configuration.errors.full_messages
        }
      )
    end
  end

  private

  def confirm_file_configuration_update
    render turbo_stream: turbo_stream.replace(
      "remote_modal", partial: "confirm_file_configuration_update", locals: {
        organisation: @organisation,
        current_file_configuration: @file_configuration,
        new_file_configuration: FileConfiguration.new(**formatted_params.compact_blank)
      }
    )
  end

  def file_configuration_params
    params.require(:file_configuration).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def formatted_params
    # we nullify blank column names for validations to be accurate
    file_configuration_params.to_h do |k, v|
      [k, k.to_s.in?(FileConfiguration.column_names_array) ? v.presence : v]
    end
  end

  def set_organisation
    @organisation = policy_scope(Organisation).find(params[:organisation_id])
    authorize @organisation, :configure?
  end

  def set_file_configuration
    @file_configuration = FileConfiguration.find(params[:id])
  end
end
