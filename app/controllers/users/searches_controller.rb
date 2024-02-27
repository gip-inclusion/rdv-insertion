module Users
  class SearchesController < ApplicationController
    before_action :set_organisations, :search_users, only: [:create]

    def create
      render json: { success: true, users: UserBlueprint.render_as_json(@users, view: :extended) }
    end

    private

    def search_users
      @users = User.active.where(id: search_in_all_users.ids + search_in_department_organisations.ids)

      preload_users_associations
      keep_only_authorized_rdvs
      keep_only_authorized_tags
    end

    def preload_users_associations
      @users = @users.preload(
        :referents, :archives,
        invitations: [rdv_context: :motif_category],
        rdv_contexts: [:participations],
        organisations: [:motif_categories, :department, :configurations]
      )
    end

    def keep_only_authorized_rdvs
      @users = @users.includes(rdv_contexts: [participations: :rdv])
                     .references(:rdv)
                     .where("rdvs.organisation_id" => agent_organisations)
    end

    def keep_only_authorized_tags
      @users = @users.includes(tags: :tag_organisations)
                     .references(:rdv, :tag_organisations)
                     .where("tag_organisations.organisation_id" => agent_organisations)
                     .distinct
    end

    def agent_organisations
      @agent_organisations ||= current_agent.organisations.ids + [nil]
    end

    def search_in_all_users
      User
        .where(nir: formatted_nirs)
        .or(User.where(email: users_params[:emails]))
        .or(User.where(phone_number: formatted_phone_numbers))
        .select(:id)
    end

    def formatted_phone_numbers
      users_params[:phone_numbers].map do |phone_number|
        PhoneNumberHelper.format_phone_number(phone_number)
      end.compact
    end

    def formatted_nirs
      users_params[:nirs].map { |nir| NirHelper.format_nir(nir) }.compact
    end

    def search_in_department_organisations
      User
        .joins(:organisations)
        .where(organisations: @organisations, department_internal_id: users_params[:department_internal_ids])
        .or(
          User
          .joins(:organisations)
          .where(organisations: @organisations, uid: users_params[:uids])
        ).select(:id)
    end

    def users_params
      params.require(:users).permit(
        nirs: [], department_internal_ids: [], uids: [], emails: [], phone_numbers: []
      ).to_h.deep_symbolize_keys
    end

    def set_organisations
      @organisations = Organisation.where(department_id: params[:department_id])
    end
  end
end
