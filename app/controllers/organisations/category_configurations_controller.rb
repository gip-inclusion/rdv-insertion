module Organisations
  class CategoryConfigurationsController < ApplicationController
    before_action :set_organisation
    before_action :set_department, :set_available_motif_categories, only: [:new]
    before_action :set_category_configuration, only: [:destroy]

    def new
      @category_configuration = CategoryConfiguration.new(organisation: @organisation)
      render layout: "no_footer_white_bg"
    end

    def create
      @category_configuration = CategoryConfiguration.new(organisation: @organisation)
      @category_configuration.assign_attributes(**category_configuration_params.compact_blank)
      if create_configuration.success?
        flash[:success] = "La configuration a été créée avec succès"
        redirect_to organisation_configuration_categories_path(@organisation)
      else
        turbo_stream_display_error_modal(create_configuration.errors)
      end
    end

    def destroy
      @category_configuration.destroy!
      flash[:success] = "La configuration a été supprimée avec succès"
      redirect_to organisation_configuration_categories_path(@organisation)
    end

    private

    PERMITTED_PARAMS = [
      { invitation_formats: [] }, :convene_user, :rdv_with_referents, :file_configuration_id,
      :invite_to_user_organisations_only, :number_of_days_before_invitations_expire, :motif_category_id,
      :phone_number, :email_to_notify_no_available_slots, :email_to_notify_rdv_changes
    ].freeze

    def category_configuration_params
      params.expect(category_configuration: PERMITTED_PARAMS).to_h.deep_symbolize_keys
    end

    def create_configuration
      @create_configuration ||= ::CategoryConfigurations::Create.call(category_configuration: @category_configuration)
    end

    def set_organisation
      @organisation = Organisation.find(params[:organisation_id])
      authorize @organisation, :configure?
    end

    def set_department
      @department = @organisation.department
    end

    def set_category_configuration
      @category_configuration = @organisation.category_configurations.find(params[:id])
    end

    def set_available_motif_categories
      already_configured_ids = @organisation.category_configurations.pluck(:motif_category_id)
      @available_motif_categories = MotifCategoryPolicy.authorized_for_organisation(@organisation)
                                                       .where.not(id: already_configured_ids)
    end
  end
end
