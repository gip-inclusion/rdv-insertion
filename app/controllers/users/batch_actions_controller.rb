module Users
  class BatchActionsController < ApplicationController
    before_action :set_organisation, :set_department, :set_organisations, :set_all_configurations,
                  :set_current_configuration, :set_current_motif_category, :set_motif_category_name, :set_users,
                  for: :new

    def new; end

    private

    def set_organisation
      return if department_level?

      @organisation = Organisation.find(params[:organisation_id])
      authorize @organisation, :batch_actions?
    end

    def set_department
      @department = department_level? ? Department.find(params[:department_id]) : @organisation.department
      authorize @department, :batch_actions? if department_level?
    end

    def set_organisations
      @organisations = policy_scope(Organisation).where(department: @department)
    end

    def set_all_configurations
      @all_configurations =
        policy_scope(::Configuration).joins(:organisation)
                                     .where(current_organisation_filter)
                                     .uniq(&:motif_category_id)
    end

    def set_current_configuration
      return unless params[:motif_category_id]

      @current_configuration =
        @all_configurations.find { |c| c.motif_category_id == params[:motif_category_id].to_i }
    end

    def set_motif_category_name
      @motif_category_name = @current_configuration&.motif_category_name
    end

    def set_current_motif_category
      @current_motif_category = @current_configuration&.motif_category
    end

    def set_users
      @users = policy_scope(User)
               .active.distinct
               .where(department_level? ? { organisations: @organisations } : { organisations: @organisation })
               .where.not(id: @department.archived_users.ids)
               .joins(:rdv_contexts)
               .where(rdv_contexts: { motif_category: @current_motif_category })
               .where.not(rdv_contexts: { status: "closed" })
    end
  end
end
